# Automating PowerVC using Ansible

Example Ansible configuration and playbooks for PowerVC. These files complement
the IBM Power Systems Blog Post [Automating PowerVC using Ansible][1].

## Requirements

The OpenStackSDK python module is required:

    pip install openstacksdk

For Ansible >= 2.10 (and optionally for Ansible v2.9) the ['openstack.cloud' Ansible collection][4] is required:

    ansible-galaxy collection install openstack.cloud

Note: Use example files in [ansible_v2.8](ansible_v2.8/) when *not* using collections.

Authentication is handled by openstacksdk, which can be configured in many
ways. See [Configuring OpenStack SDK Applications][3] for details.

[1]: https://developer.ibm.com/tutorials/automating-powervc-using-ansible/
[2]: https://docs.ansible.com/ansible/latest/modules/os_server_module.html
[3]: https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html
[4]: https://galaxy.ansible.com/openstack/cloud
