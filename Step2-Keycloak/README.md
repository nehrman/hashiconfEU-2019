# hashiconfEU-2019 - Securing your apps without touching code !!!
## Step 2 - Adding Authentication and Authorization with Keycloak

After Step 1 where we illustrate how to integrate Vault and cert-manager to automate certificate insuance for ingress route in Kubernetes, let's continue with this demo to demonstrate how to use [Keycloak](https://www.keycloak.org/) and some minor change in your Application to add authentication and authorization.

Here are the technologies and features used in this demo:
- [Terraform](https://www.terraform.io)
- [Minikube with Nginx as Ingress Router](https://kubernetes.io/docs/tasks/tools/install-minikube/)
- [Cert-manager](https://github.com/jetstack/cert-manager)
- [Vault with PKI Secret Engine](https://www.vaultproject.io)
- [Fabric8](https://fabric8.io/)
- [Keycloak](https://www.keycloak.org/)

As always, let's look at what we're gonna do in terms of workflow and architecture.

<img width="800" alt="Step 2" src="../Assets/SecureYourApp_Step2.png">


## Special thanks

* **Laurent Broudoux** - For the App code and for working together on that project [Github](https://github.com/lbroudoux)

## Authors

* **Nicolas Ehrman** - *Initial work* - [Hashicorp](https://www.hashicorp.com)