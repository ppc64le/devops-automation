#!/bin/ksh

#  Copyright: IBM Corp. , 2017
#
#  Written by: Stephen Poon, Ralf Schmidt-Dannert, IBM
#              IBM Washington Systems Center, NA - Power Technical Team, Oracle
#  
#  Disclaimers:
#  This script is provided as-is to illustrate Oracle Database as a Service
#  with IBM PoverVC. This script is not part of any IBM product and has not
#  undergone extended testing of functionality or "fit for purpose" verification
#
#  Legal Stuff:
#
#  No Warranty
#  Subject to any statutory warranties which can not be excluded, IBM makes
#  no warranties or conditions either express or implied, including without
#  limitation, the warranty of non-infringement and the implied warranties
#  of merchantability and fitness for a particular purpose, regarding the
#  program or technical support, if any.
#
#  Limitation of Liability
#  Neither IBM nor its suppliers will be liable for any direct or indirect
#  damages, including without limitation, lost profits, lost savings, or any
#  incidental, special, or other economic consequential damages, even if IBM
#  is informed of their possibility. Some jurisdictions do not allow the
#  exclusion or limitation of incidental or consequential damages, so the
#  above exclusion or limitation may not apply to you.
#----------------------------------------------------------------------
#
#   prep_image_capture.sh
#  
#   This script prepares the image source VM for rc.oracledbaasv3
#      for image capture.
# 
#    Change history:  08/10/2016 rsd: new
#                     08/24/2016 srp: rmitab old entries (grep for dbaas)
#                                     clean up oem 12c and 13c base directories
#                                     print informational log message on rc.agent version
#                                       and OEM host settings
#		      02/15/2017 srp: change itab to initdbaas (incorporate changes for vRA)
#                     02/21/2017 srp: remove trigger file
#		      04/30/2017 rsd: Version change to v3
#
LOGFILE=$0.log
> $LOGFILE

logmsg()
{
        echo "** "`date +"%T %m/%d/%y"` `basename $0`: "$1" | tee -a $LOGFILE
}

if [ `id -u` != "0" ]; then
	logmsg "This reset script has to be run as root!"
	logmsg "Abort."
	exit 1
fi

logmsg "starting from `dirname $0`"
logmsg "preparing image source host"
if [[ -f /stage/rc.agent12c.cfg ]]; then
	. /stage/rc.agent12c.cfg
	if [ "$AGENT_BASE_DIR" = "." -o "$AGENT_BASE_DIR" = "" ]; then
		logmsg "AGENT_BASE_DIR not set correctly: $AGENT_BASE_DIR"
		exit 2
	fi
	logmsg "cleaning up $AGENT_BASE_DIR"
	rm -rf $AGENT_BASE_DIR/*
fi

if [[ -f /stage/rc.agent13c.cfg ]] then
	. /stage/rc.agent13c.cfg
	if [ "$AGENT_BASE_DIR" = "." -o "$AGENT_BASE_DIR" = "" ]; then
		logmsg "AGENT_BASE_DIR not set correctly: $AGENT_BASE_DIR"
		exit 2
	fi
	logmsg "cleaning up $AGENT_BASE_DIR"
	rm -rf $AGENT_BASE_DIR/*
fi

ITABS=`lsitab -a | grep dbaas | cut -d":" -f 1`
if [[ ${#ITABS} -gt 0 ]]; then
	logmsg "remove inittab entrie(s) $ITABS"
	for i in $ITABS; do
		rmitab "$i"
	done
fi
logmsg "Add call to /stage/rc.initdbaas to inittab"
/usr/sbin/mkitab "initdbaas:2:once:/stage/rc.initdbaas > /tmp/rc.initdbaas.log 2>&1 &"


# generate pvid to vg mappings (cloud-init) in case something changed
/opt/freeware/lib/cloud-init/create_pvid_to_vg_mappings.sh

logmsg "removing files"
rm -f /tmp/*.ora
rm -f /tmp/*.log
rm -f /tmp/user-data.txt
rm -f /stage/*.log
rm -f *.out
rm -rf /tmp/.workdir*
rm -rf /tmp/*sysasm
rm -rf /tmp/*.file
rm -rf /u01/app/oracle/cfgtoollogs/netca/*
rm -rf /u01/app/oracle/cfgtoollogs/dbca/*
rm /u01/app/grid/product/12.1.0/grid/network/admin/listener.ora.bak.dbaasv3

logmsg "cleaning shell history and user ssh keys"
rm -f ~root/.ssh/known_hosts
rm -f ~root/.vnc/*log
rm -f ~root/.vnc/*pid
rm -f ~root/.vnc/*passwd
rm -f ~root/.vi_history
> ~root/.sh_history

rm -f ~oracle/.ssh/known_hosts
rm -f ~oracle/.vnc/*log
rm -f ~oracle/.vnc/*pid
rm -f ~oracle/.vnc/*passwd
rm -f ~oracle/.vi_history
> ~oracle/.sh_history

rm -f ~grid/.ssh/known_hosts
rm -f ~grid/.vnc/*log
rm -f ~grid/.vnc/*pid
rm -f ~grid/.vnc/*passwd
rm -f ~grid/.vi_history
> ~grid/.sh_history

logmsg "setting ownership and permissions for /tmp/clone_work*"
chown -R oracle:oinstall /tmp/clone_work*

errclear 0

#  source the cfg file for environment variables
. rc.oracledbaasv3.cfg

logmsg "attempting to stop has"
logmsg "The following error is expected"
logmsg "=========================="
$GRID_HOME/bin/crsctl stop has | grep CRS-4047
ecode=$?
logmsg "=========================="

if [ $ecode -ne 0 ]; then
        logmsg "deconfiguring has"
        $GRID_HOME/perl/bin/perl -I$GRID_HOME/perl/lib -I$GRID_HOME/crs/install $GRID_HOME/crs/install/roothas.pl -deconfig -force
fi

logmsg "clearing system error log"
errclear 0

logmsg "Verifying listener.ora contents."
export GRID_HOME=/u01/app/grid/product/12.1.0/grid
lstname=`awk '/HOST/ { print $7;}' ${GRID_HOME}/network/admin/listener.ora`
lstname=`echo $lstname | awk -F')' '{ print $1;}'`
if [ "${lstname}" != "DEPLOYHOST" ]
then
  sed "s/${lstname}/DEPLOYHOST/" ${GRID_HOME}/network/admin/listener.ora > /tmp/listener.ora
  if [ $? -eq 0 ]; then
    mv /tmp/listener.ora ${GRID_HOME}/network/admin/listener.ora
    chown grid:oinstall ${GRID_HOME}/network/admin/listener.ora
  fi
fi

logmsg "IMPORTANT: ============================================="
logmsg "IMPORTANT: review the following settings for OEM"
VAROEMAGENT=`grep "^export OEMAGENTSCRIPT" rc.oracledbaasv3.cfg | cut -d"=" -f 2 | tr -d '"'`
logmsg "rc.oracledbaasv3.cfg is set up to call $VAROEMAGENT"
VAROEMHOST=`grep "^export OMS_HOST" /stage/$VAROEMAGENT.cfg | cut -d"=" -f 2`
logmsg "$VAROEMAGENT.cfg OMS_HOST is set to $VAROEMHOST"
VARCLONEDIR=`grep "^export T_WORK" /stage/$VAROEMAGENT.cfg | cut -d"=" -f 2`
if [ -d $VARCLONEDIR ]; then
	logmsg "$VARCLONEDIR exists"
else
	logmsg "ERROR: $VARCLONEDIR does not exist"
fi
logmsg "--------------------------------------------------------"

logmsg "ended"
