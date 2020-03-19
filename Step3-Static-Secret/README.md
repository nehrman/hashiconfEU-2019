# hashiconfEU-2019 - Securing your apps without touching code !!!
## Step 3 - Adding Static Secret Management to your app

Just a quick reminder on what we did so far :
- Step 1 : Use Jetstack/cert-manager and Vault to provide TLS for Ingress Traffic
- Step 2 : Adding Authentication and Authorization with Keycloak

Now, that's the third step of our journey to a highly secure application where we're gonna introduce Static Secrets management with [Vault](https://www.vaultproject.io) from Hashicorp in order to not rely on Kubernetes secrets but provide a more secure way to distribute secrets.

Here are the technologies and features used in this demo:
- [Terraform](https://www.terraform.io)
- [Minikube with Nginx as Ingress Router](https://kubernetes.io/docs/tasks/tools/install-minikube/)
- [Vault with Static (K/V) Secret Engine](https://www.vaultproject.io)

Like we did from the beginning of this demo, let's look at what we're gonna do in terms of workflow and architecture.

<img width="800" alt="Step 3" src="../Assets/SecureYourApp_Step3.png">

## Ok, now, we're ready to use terraform code to deploy step 3
Of course, we will not cover how to [download](https://releases.hashicorp.com/terraform/) and [configure](https://learn.hashicorp.com/terraform/getting-started/install.html) it, as we supposed you already have it.

1. **Configure Env variables** - To be able to connect to vault, we need to set up VAULT_TOKEN with that command:
    ```bash
    export VAULT_TOKEN=root
    ```
    That's the only variable we have to configure for vault provider for terraform. All others variables are defined in the **variables.tf** file.

2. **Import Fruits-catalog Deployment in your State file** - And probably you're asking yourself why ? In fact, in step 1 and 2 we used Fabric8 to  build and deploy our Application on K8s. But now, we're gonna use Terraform to be able to automate our apps deployment. In order to do that, we     have to use that command:
    ```bash
    $>terraform import kubernetes_deployment.fruits-catalog fruits-catalog/fruits-catalog
    ```

    Check that you have well imported your ressource:
    <img width="800" alt="Terraform Import" src="../Assets/Step3_tf_import.png">

3. **Analyze the code to understand what we're gonna do** - As always, we check the code before doing any further actions:
    - Configuring a K/V Secret Engine on Vault
    - Creating a specific service account (vault-auth) on K8s 
    - Configuring ClusterRoleBinding to give Role-Token_reviewer to the service account
    - Enabling and configuring Kubernetes Auth method on Vault
    - Populating K/V with MongoDB secrets needed by the app
    - Creating a policy to give read access to kv/fruits-catalog-mongodb
    - Creating a specifc role on kubernetes auth method attached to the specific policy

4. **It's time to use Terraform** - That's not the final step, but at least, you don't have to do everything manually :)
    - Run terraform init to prepare the environment:
    ```bash
    $>terraform init
    ```
    - Run terraform plan to see if everything is correct: 
    ```bash
    $>terraform plan
    ```
    - And finally, run terraform apply to make the magic happen: 
    ```bash
    $>terraform apply
    ```

    You should end up with something like this:
    
    <img width="800" alt="Terraform Apply" src="../Assets/Step3_tf_apply.png">

## Validate everything is working as expected
Now, your application is using an init container which uses the service account token from K8s to: 
- Connect to vault 
- Retrieve the secrets
- Register secrets in application.properties file in a shared volume 

To ensure everything is work as expected, follow the below steps.

1. **Validate log on the init-container** - Here, we're gonna check if init-container was able to retrieve the secret and create the correct files.
    - First, you need to launch the minikub's dashboard with that command:
    ```bash
    $>minikube dashboard
    ```
    Your browser should popup with the Kubernetes Dashboard

    <img width="800" alt="K8S Dashboard" src="../Assets/Step3_k8s_dashboard.png">
    
    - Select the fruits-catalog namespace, then pods, then your fruits-catalog pod and finally click on **log**:

    <img width="800" alt="Fruits Catalog Pod" src="../Assets/Step3_k8s_pod.png">
    
    - Click on **logs from** and select **vault-init**, you should see no errors:

    <img width="800" alt="Vault-Init Log" src="../Assets/Step3_k8s_log.png">

2. **Validate configuration files on spring-boot container**: Now, we want to check that we're really using the secrets from vault and not from Kubernetes.
    - Connect to your container using that command:
    ```bash
    $>kubectl exec -ti fruits-catalog-8575f96cb4-dktdr -c spring-boot /bin/bash
    ```

    <img width="800" alt="Pod Shell" src="../Assets/Step3_pod_shell.png">

    - Go to /etc/app/ and read the application.properties. You should see something like this: 

    <img width="800" alt="Application Properties" src="../Assets/Step3_pod_app.png">

3. **Connect to the app and validate all your datas are sitll there** - Finally, we connect to our apps to validate that all is working perfectly.
    - Connect thru your browser to your application with https://fruits.testalb.local and enter your username and password configured in step 2.
    
    <img width="800" alt="Fruits Catalog Login" src="../Assets/Step3_app_login.png">

    - Vaildate that all your previous fruits are still there and that you can add more.

     <img width="800" alt="Fruits Catalog Working" src="../Assets/Step3_app_working.png">


*Congrats*, without touching your application code, you add a non negligeable security layer by externalizing and centralizing your secrets on Vault.

We're ready to move on to step 4 and add Dynamic Secret management to add another layer of security.

## Special thanks

* **Laurent Broudoux** - For the App code and for working together on that project [Github](https://github.com/lbroudoux)

## Authors

* **Nicolas Ehrman** - *Initial work* - [Hashicorp](https://www.hashicorp.com)