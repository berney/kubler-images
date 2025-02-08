# Terraform

This Terraform code sets up the Azure resources necessary for this GitHub repository's workflows to be able to authenticate to Azure via OpenID Connect.
It does this by creating User Assigned Managed Identities with Federated Credentials configured.
This setup needs to be done before GitHub workflows can work, so it needs to be done locally.
It only needs to be done once.
That is once you have done `terraform apply`, the GitHub Workflows should be able to start using Azure, and you won't need to run terraform again.
You will need to login with the Azure CLI so that Terraform can create the Azure resources.
Because the GitHub Workflows need a few variables configured based on values from the created Azure resources, the terraform code does this for you.
In order for it to be able to set these variables in GitHub it requires the GitHUB Personal Access Token (PAT).

We use Docker to ease using Terraform, which with the Azure provider requires the Azure CLI.
The Azure CLI is a pain to install, so using Docker is much nicer.

The `Dockerfile` takes Microsoft's Azure CLI image and adds Terraform to it from Hashicorp's Terraform image.
There is a `docker-compose.yml` file so all you need is `docker compose run --rm terraform`.

## Quick Start

. Setup GitHUB PAT
. `docker compose run --rm terraform`
. `az login`
. `gh auth login`
. `terraform apply`

