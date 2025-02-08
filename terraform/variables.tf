variable "prefix" {
  type    = string
  default = "berney-github"
}

variable "location" {
  type = string
  #default = "Australia East"
  default = "West US"
}

variable "github_organisation" {
  type = string
  default = "berney"
}

variable "github_repository" {
  type = string
  default = "kubler-images"
}

#variable "github_token" {
#  type = string
#  sensitive = true
#  description = <<-EOF
#    GitHUB Personal Access Token (PAT) so that terraform can configure the necessary GitHub Workflow variables to be able to use OpenID Connect (OIDC) to login to Azure.
#EOF
#}

