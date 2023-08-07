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
  #arn = "arn:aws:secretsmanager:ap-southeast-1:319725399868:secret:PrismaCloud_CED-VAeRX0"
  arn = "arn:aws:secretsmanager:ap-southeast-1:319725399868:secret:PrismaCloud-gihFSS"
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

resource "prismacloud_rql_search" "x" {
    search_type = "config"
    query = "config from cloud.resource where api.name = 'aws-ec2-key-pair' AND json.rule = keyName exists"
    time_range {
        relative {
            unit = "hour"
            amount = 24
        }
    }
}

resource "prismacloud_saved_search" "example" {
    name = "CJ demo aws EC2s"
    description = "cj demo"
    search_id = prismacloud_rql_search.x.search_id
    query = prismacloud_rql_search.x.query
    time_range {
        relative {
            unit = prismacloud_rql_search.x.time_range.0.relative.0.unit
            amount = prismacloud_rql_search.x.time_range.0.relative.0.amount
        }
    }
}