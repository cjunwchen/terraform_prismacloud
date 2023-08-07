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

data "prismacloud_policy" "demo" {
    name = "EC2 Instance NOT t2.nano - CJ Demo"
}

output "prismacloud_policy" {
    value = data.prismacloud_policy.demo.rule
}