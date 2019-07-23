# hashiconfEU-2019 - Securing your apps without touching code !!!

This demo was used during my talk @ HashiconfEU 2019 - Tech-Leaders Track.
It demonstrates how to highly secure a java application without touching code and is divided in 5 steps :
- Step 1 : Use Jetstack/cert-manager and Vault to provide TLS for Ingress Traffic
- Step 2 : Adding Authentication and Authorization with Keycloak
- Step 3 : Moving from K8s secrets to Vault Static Secrets
- Step 4 : Adding even more security with Vault Dynamic Secrets for MongoDB
- Step 5 : Introduce service segmentation with Consul Connect

<img width="800" alt="Demo Workflow" src="./Assets/Workflow.png">

Each steps will be detailed in its own folder.

## Special thanks

* **Laurent Broudouc** - For the App code and for working together on that project [Github](https://github.com/lbroudoux)

## Authors

* **Nicolas Ehrman** - *Initial work* - [Hashicorp](https://www.hashicorp.com)