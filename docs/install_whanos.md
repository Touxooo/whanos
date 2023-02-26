# How to install Whanos

## Prerequisites

- Configured Google Cloud Account
- Terraform

## Set up GCP

After creating your GCP account, create or modify the following resources to enable Terraform to provision your infrastructure:

- A GCP Project: GCP organizes resources into projects. [Create one now](https://console.cloud.google.com/projectcreate) in the GCP console and make note of the project ID. You can see a list of your projects in the [cloud resource manager](https://console.cloud.google.com/cloud-resource-manager).

- Google Compute Engine: Enable Google Compute Engine for your project [in the GCP console](https://console.developers.google.com/apis/library/compute.googleapis.com). Make sure to select the project you are using to follow this tutorial and click the "Enable" button.

- Google Kubernetes Engine: Enable Kubernetes Engine for your project [in the GCP console](https://console.cloud.google.com/marketplace/product/google/container.googleapis.com). Make sure to select the project you are using to follow this tutorial and click the "Enable" button.

- A GCP service account key: [Create a service account key](https://console.cloud.google.com/apis/credentials/serviceaccountkey) to enable Terraform to access your GCP account. When creating the key, use the following settings:

  - Select the project you created in the previous step.
  - Click "Create Service Account".
  - Give it any name you like and click "Create".
  - For the Role, choose "Project -> Editor", then click "Continue".
  - Skip granting additional users access, and click "Done".

    After you create your service account, download your service account key.

  - Select your service account from the list.
  - Select the "Keys" tab.
  - In the drop down menu, select "Create new key".
  - Leave the "Key Type" as JSON.
  - Click "Create" to create the key and save the key file to your system.

    You can read more about service account keys in [Google's documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

Source: [Terraform: GCP Get Started](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build)

## Set up Terraform

1. Install Terraform from your favorite package manager

2. Clone the Whanos

```sh
git clone https://github.com/Touxooo/whanos.git
```

3. Put your previous generated json key at the root of the repo with the name `key.json`

4. Replace the variables within `variables.tf` by your.

## Install Whanos

1. Set the registry host and jenkins admin password in the `.env` file.

   **Registry Host**

   [GCLOUD_LOCATION].pkg.dev/[GCLOUD_PROJECT]

   Example: europe-west9-docker.pkg.dev/whanos-terraform-test

2. Init Terraform within terraform/ folder

```sh
cd terraform && terraform init
```

3. Make a plan to see all changes coming

```sh
terraform plan
```

4. Once you agree with all changes, apply the terraform configuration

```sh
terraform apply
```

5. Wait 5 to 10 minutes the installation of Whanos on the Google Cloud servers

6. Copy the external IP you have on your terraform output

7. Paste the IP on your web navigator

8. Enjoy your whanos! If you don't know how to use it, go to this [documentation](setup_whanos.md)
