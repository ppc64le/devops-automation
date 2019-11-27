# IBM Cloud Manager deployment template files for *oraclient*
This folder can be directly imported into CAM to define the *oraclient* template. This template can not be deployed by itself as it expects as input output values from the deployment of *oradbaas* template.

Note that at deploy time two 3rd party software packages are required to be available via a NFS server:
* Oracle Instant Client (For downloads see: [Oracle Instant Client Downloads](https://www.oracle.com/database/technologies/instant-client/downloads.html))
* Swingbench (For details and downloads see: [Swingbench](http://www.dominicgiles.com/swingbench.html))