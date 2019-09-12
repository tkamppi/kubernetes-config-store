# Deploy Kubernetes as a configuration store

## Select GCP project

Select the project in which you'll install Spinnaker, then click **Start**, below.

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Configure

Let's start by setting the configuration variables required.
Click the **Copy to Cloud Shell** button below, and press **Enter**

```bash
PROJECT_ID={{project-id}} bash ~/kubernetes-config-store/scripts/generate_configuration.sh
``` 

## Check configuration

If you wish to modify the default configuration, run the below command and save your changes.

```bash
cloudshell edit ~/kubernetes-config-store/scripts/configuration
```

## Start the setup process

Now let's deploy the regional GKE cluster without nodes, and the Cloud Function for the JSON API.

```bash
bash ~/kubernetes-config-store/scripts/setup.sh
```

## Access the function

You could grant yourself permission to access to invoke the Cloud function by running:

```bash
bash ~/kubernetes-config-store/scripts/grant_permission.sh
```
