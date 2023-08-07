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

resource "prismacloud_policy" "Run_Policy_Demo" {
  policy_type = "config"
  cloud_type  = "aws"
  name        = "CJ Demo - sample run policy created with terraform"
  severity = "low"
  labels      = ["cjdemo"]
  description = "this describes the policy"
  recommendation = "Follow recommendation steps"
  rule {
    name     = "CJ Demo - sample run policy created with terraform"
    rule_type = "Config"
  
    parameters = {
      savedSearch = false
      withIac     = false
    }
    criteria = file("policies/aws/cj_run_policy_001.rql")
  }

  remediation {
   cli_script_template = "aws iam update-account-password-policy --minimum-password-length 14 --require-uppercase-characters --require-lowercase-characters --require-numbers --require-symbols --allow-users-to-change-password --password-reuse-prevention 24 --max-password-age 90"
   description = "This CLI command requires 'iam:UpdateAccountPasswordPolicy' permission. Successful execution will update the password policy to set the minimum password length to 14, require lowercase, uppercase, symbol, allow users to reset password, cannot reuse the last 24 passwords and password expiration to 90 days."
  }
  
}