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

resource "prismacloud_policy" "Build_Policy_Demo" {
  name        = "cj demo build policy"
  policy_type = "config"
  cloud_type  = "aws"
  severity    = "high"
  labels      = []
  description = ""
  recommendation = ""
  rule {
    name = "cj demo build policy"
    rule_type = "Config"
    parameters = {
      savedSearch = false
      withIac     = true
    }
    children {
      type           = "build"
      recommendation = "fix it"
      metadata = {
        "code" : file("policies/cj_demo_001.yaml"),
      }
    }
  }
}

/*
resource "prismacloud_policy" "bPolicy" {
  name        = "Ensure resources are only created in permitted locations"
  policy_type = "config"
  cloud_type  = "azure"
  severity    = "high"
  labels      = []
  description = ""
  recommendation = ""
  rule {
    name = "Ensure resources are only created in permitted locations"
    rule_type = "Config"
    parameters = {
      savedSearch = false
      withIac     = true
    }
    children {
      type           = "build"
      recommendation = "fix it"
      metadata = {
        "code" : file("policies/cj_demo_002.yaml"),
      }
    }
  }
} 
*/

 