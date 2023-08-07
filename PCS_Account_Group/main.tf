terraform {
  required_providers {
    prismacloud = {
      source = "PaloAltoNetworks/prismacloud"
      // version = "1.3.7"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_secretsmanager_secret" "prisma_cloud_cred" {
  arn = "arn:aws:secretsmanager:ap-southeast-1:319725399868:secret:PrismaCloud_CED-VAeRX0"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.prisma_cloud_cred.id
}

provider "prismacloud" {
    url= jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["pcs-url"]
    username= jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["pcs-username"]
    password= jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["pcs-password"]
    #pcs-tenant = "Palo Alto Networks (TEST ACCT) - 265229206683231531"
    protocol= "https"
    port= "443"
    timeout= "90"
    skip_ssl_cert_verification= "true"
    # logging= "quiet"
    disable_reconnect= "false"
    json_web_token= ""
    json_config_file= ""
}

/*
locals {
    instances = csvdecode(file("aws.csv"))
}
*/

variable "acc_id" {
  type = string
  default = "408551503499"
}

data "external" "ou_name" {
  program = ["bash", "${path.module}/aws_ou_query.sh","${var.acc_id}"]
}

resource "prismacloud_account_group" "current" {
    name = data.external.ou_name.result["ou_name"]
    description = "Dynamic Create Account Group Demo"
}

output "PrismaCloud_Acc_Grp" {
  value = prismacloud_account_group.current.group_id
}