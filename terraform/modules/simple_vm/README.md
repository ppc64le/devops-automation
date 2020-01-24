# ibmcloud\_simple\_vm 

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ibmcloud\_api\_key | IBM Cloud API Key | string | n/a | yes |
| create | Whether to create this resource or not? | bool | `"true"` | no |
| basename | Denotes the name of the VPC to deploy into. Resources associated will be prepended with this name. | string | some | yes |
| boot\_image\_id | UUID of the base image for the virtual server | string | r134-d2f5be47-f7fb-4e6e-b4ab-87734fd8d12b | yes |
| vpc\_region | Target region to create this instance | string | us-south | yes |
| vpc\_zone | Target availbility zone to create this instance | string | us-south-3 | yes |
| tcp_\__ports | Comma delimitted TCP ports to open in VPC security group | string | 22,80,443 | yes |
| vm\_profile | VM profile to provision | string | cp2-2x4 | yes |

## Outputs

| Name | Description |
|------|-------------|
| ip\_address | The floating ip address of the VM |
| ssh\_rule | The ssh rule id to let the user know when the ssh rule has been created |
| instance\_ssh\_private | The ssh private key to login to ssh console |
