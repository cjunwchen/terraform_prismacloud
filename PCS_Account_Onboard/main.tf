provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_providers {
    prismacloud = {
      source = "PaloAltoNetworks/prismacloud"
      // version = "1.3.7"
    }
  }
}

data "aws_secretsmanager_secret" "prisma_cloud_cred" {
  arn = [arn of AWS Secret ID for Prisma Cloud Credential]
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.prisma_cloud_cred.id
}

provider "prismacloud" {
    url= jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["pcs-url"]
    username= jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["pcs-username"]
    password= jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["pcs-password"]

    protocol= "https"
    port= "443"
    timeout= "90"
    skip_ssl_cert_verification= "true"
    # logging= "quiet"
    disable_reconnect= "false"
    json_web_token= ""
    json_config_file= ""
}

locals {
    instances = csvdecode(file("aws.csv"))
}

module "PrismaCloud-AWS-Onboarding" {
  source = "./pcs-aws-acc-onboard"
  for_each = { for inst in local.instances : inst.name => inst }

  account_id = each.value.accountId
  pcs-cloud-acc-name = each.value.name
  pcs-account-grp-name = var.pcs-account-grp-name
  aws_org_account_id = var.pcs-aws-mgmt-account-id
}

