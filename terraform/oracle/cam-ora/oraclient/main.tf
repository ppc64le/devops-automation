######################################################################
#  Copyright: IBM Corp., 2019
#
#  Written by: Stephen Poon, Ralf Schmidt-Dannert
#              IBM North America Systems Hardware
#              Power Technical Team, Oracle
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  
#----------------------------------------------------------------------
#####################################################################
##
##      Deploy LOP with Oracle client and Swingbench for oraclient
##
#####################################################################
#
#  Note that the text <MY_NFS_SERVER_IP> needs to be replaced with the
#  hostname or IP of your NFS server in the line:
#  - mount <MY_NFS_SERVER_IP>:/export/stage /mnt
#####################################################################

terraform {
  required_version = "> 0.8.0"
}

provider "openstack" {
  insecure    = true
  version = "~> 1.2"
}

resource "openstack_compute_instance_v2" "dbclient" { 
  name  = "${format("${var.dbclient_name}-${var.dbserver_user_data}-${var.dbserver_ts}")}"
  image_name  = "${var.openstack_image_name_dbclient}"
  flavor_name = "${var.openstack_flavor_name_dbclient}"
  user_data = <<EOT
#cloud-config
write_files:
  - content: |
     # dbserver parameters
     ${format("export DBNAME=%s",var.dbserver_user_data)}
     ${format("export DBSERVERIPADDR=%s",var.dbserver_ipaddr)}
     export ORASYSPW=oracle
     export SWINGBENCHBINDIR=/opt/swingbench/bin
    path: /root/dbserver.cfg
  - content: |
     cd ~
     . ./.bash_profile
     . ./dbserver.cfg
     DBACTIVE=false
     MAXLOOP=30
     LOOPDELAY=10
     i=1
     while [ "$DBACTIVE" = false ] && [ "$i" -le $MAXLOOP ] ; do
       sqlplus system/$ORASYSPW@$DBSERVERIPADDR/$DBNAME < /dev/null | grep "Connected to"
       if [ "$?" -eq 0 ]; then
           echo "Oracle DB server active"
           TEMP=`sqlplus -s system/$ORASYSPW@$DBSERVERIPADDR/$DBNAME << EOF1
           set pages 0
           set head off
           set feed off
           select open_mode, database_status, shutdown_pending from v\\$database, v\\$instance;
           exit
     EOF1`
       TEMP2=`echo $TEMP | tr -d ' '` 
       if [ "$TEMP2" = "READWRITEACTIVENO" ]; then
            DBACTIVE=true
            echo "Oracle DB server open in READ WRITE mode"
       fi
       else
           if [ "$i" -eq 1 ]; then
                   /bin/echo -e "Waiting for Oracle DB server\c"
           fi
       fi
       sleep $LOOPDELAY
       /bin/echo -e ".\c"
       i=$(( $i + 1 ))
     done
     if [ "$DBACTIVE" = true ]; then
       TEMPFILE_NAME=`sqlplus -s system/$ORASYSPW@$DBSERVERIPADDR/$DBNAME << EOF
       set pages 0
       set head off
       set feed off
       select name from v\\$tempfile;
       exit
     EOF`
       echo tempfile name is = $TEMPFILE_NAME
       sqlplus -s system/$ORASYSPW@$DBSERVERIPADDR/$DBNAME << EOF2
       alter database tempfile '$TEMPFILE_NAME' resize 2G;
       exit
     EOF2
       cd $SWINGBENCHBINDIR
       ./oewizard -c ../wizardconfigs/oewizard.xml -bigfile -cl -create -cs //$DBSERVERIPADDR/$DBNAME -dbap $ORASYSPW -scale 1 -u soe -p soe -ts soe -tc 16    
     else
       echo "Unable to connect to database.. perhaps not active or incorrect connect information"
       echo "Retries = $i"
     fi
    path: /root/sbsetup.sh
    permissions: '0755'
  - content: |
     cd
     . ./dbserver.cfg
     cd $SWINGBENCHBINDIR
     ./oewizard -c ../wizardconfigs/oewizard.xml -cl -drop -cs //$DBSERVERIPADDR/$DBNAME -dbap $ORASYSPW -scale 1 -u soe -p soe -ts soe
    path: /root/dropsoe.sh
    permissions: '0755'
  - content: |
     cd
     . ./dbserver.cfg
     cd $SWINGBENCHBINDIR
     ./swingbench -cs "//$DBSERVERIPADDR/$DBNAME"
     cd
    path: /root/runsb.sh
    permissions: '0755'
runcmd:
  - systemctl restart vncserver@:1
  - mount <MY_NFS_SERVER_IP>:/export/stage /mnt
  - if [ `uname -p` = "ppc64le" ]; then cp /mnt/client/12g/instantclient*.leppc64.*.zip /root; elif [[ `uname -p` = "ppc64" ]]; then cp /mnt/client/12g/instantclient*.ppc64.*.zip /root; fi
  - unzip -o /mnt/Swingbench/swingbench261076.zip -d /opt
  - cd /root; for i in `ls | grep instantclient`; do unzip -o $i -d /opt; rm -f $i; done
  - chmod -R 755 /opt/swingbench /opt/instantclient_12_1
  - /bin/echo -e "export PATH=\$PATH:/opt/`ls /opt | grep instantclient` \nexport LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/`ls /opt | grep instantclient`" >> /root/.bash_profile
  - umount /mnt
  - cd /root; rm -f instantclient*.zip
  - /bin/echo -e "\n*** please wait for sbsetup.sh completion msg.." | wall
  - sleep 180; /root/sbsetup.sh >> /root/sbsetup.log 2>&1
  - /bin/echo -e "\n*** sbsetup.sh ended. See /root/sbsetup.sh.log." | wall
EOT

  network {
    name = "${var.openstack_network_name}"
  }
}
