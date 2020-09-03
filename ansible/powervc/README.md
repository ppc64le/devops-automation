# Automating PowerVC using Ansible

Example Ansible configuration and playbooks for PowerVC. These files complement
the IBM Power Systems Blog Post [Automating PowerVC using Ansible][1].

## Requirements

The Ansible OpenStack [os_server][2] module is used to create and delete
PowerVC VM instances. This requires:

* openstacksdk >= 0.12.0

This can be installed in the Ansible Python environment using pip:
`pip install "openstacksdk>=0.12.0"`

Authentication is handled by openstacksdk, which can be configured in many
ways. See [Configuring OpenStack SDK Applications][3] for details.

[1]: https://developer.ibm.com/components/ibm-power/tutorials/automating-powervc-using-ansible/
[2]: https://docs.ansible.com/ansible/latest/modules/os_server_module.html
[3]: https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html
