# IBM Cloud Manager service definition file
This service file can be directly imported into CAM, but will require adjustments to the *oradbaas* and *oraclient* template references, which have to already exist in CAM.

This service can be deployed from CAM or via the ICP catalog and orchestrates the deployment of the templates *oradbaas* and *oraclient*. The VM configuration after deployment will look like the following:

![Image Deployed Service](../service-deployed.png)
