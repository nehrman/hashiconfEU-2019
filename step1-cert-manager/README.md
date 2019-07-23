# hashiconfEU-2019 - Securing your apps without touching code !!!
## Step 1 - Use Jetstack/cert-manager and Vault to provide TLS for Ingress Traffic

This demo illustrates how to leverage [jetstack/cert-manager](https://github.com/jetstack/cert-manager) and [Vault](https://www.vaultproject.io) to automate the management and issuance of TLS certficates in K8s environment.

Here are the technologies and features used in this demo:
- [Terraform](https://www.terraform.io)
- [Minikube with Nginx as Ingress Router](https://kubernetes.io/docs/tasks/tools/install-minikube/)
- [Cert-manager](https://github.com/jetstack/cert-manager)
- [Vault with PKI Secret Engine](https://www.vaultproject.io)
- [Fabric8](https://fabric8.io/)

But, wait, what does it means in terms of architecture ?

<img width="800" alt="Step 1" src="./Assets/SecureYourApp_Step1.png">



## Special thanks

* **Laurent Broudoux** - For the App code and for working together on that project [Github](https://github.com/lbroudoux)

## Authors

* **Nicolas Ehrman** - *Initial work* - [Hashicorp](https://www.hashicorp.com)