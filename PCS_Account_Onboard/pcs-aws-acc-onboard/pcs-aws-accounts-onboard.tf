variable "aws_org_account_id" {
  type = string
}

variable "account_id" {
  type = string
}

variable "pcs-cloud-acc-name" {
  type = string
}

variable "pcs-account-grp-name" {
  type = string
}

terraform {
  required_providers {
    prismacloud = {
      source = "PaloAltoNetworks/prismacloud"
      // version = "1.3.7"
    }
  }
}

data "prismacloud_account_group" "existing_account_group_id" {
    name = var.pcs-account-grp-name
}

data "prismacloud_account_supported_features" "prismacloud_supported_features" {
    cloud_type = "aws"
    account_type = "account"
}

data "prismacloud_aws_cft_generator" "prismacloud_account_cft" {
    account_type = "account"
    account_id = var.account_id
    features = data.prismacloud_account_supported_features.prismacloud_supported_features.supported_features
}

resource "aws_cloudformation_stack_set" "PrismaCloudApp" {
  name                      = "PrismaCloudApp-${var.pcs-cloud-acc-name}"
  administration_role_arn   = "arn:aws:iam::${var.aws_org_account_id}:role/service-role/AWSControlTowerStackSetRole"
  capabilities              = ["CAPABILITY_NAMED_IAM"]
  execution_role_name       = "AWSControlTowerExecution"
  template_url = data.prismacloud_aws_cft_generator.prismacloud_account_cft.s3_presigned_cft_url  
  parameters = { 
    PrismaCloudRoleName = "PcsIamRole"
  }
}

resource "aws_cloudformation_stack_set_instance" "PrismaCloudApp-member" {
  account_id = var.account_id
  region         = "ap-southeast-1"
  stack_set_name = aws_cloudformation_stack_set.PrismaCloudApp.name
}

resource "prismacloud_cloud_account_v2" "aws_account_onboarding_example" {
    depends_on = [
      aws_cloudformation_stack_set_instance.PrismaCloudApp-member,
      aws_cloudformation_stack_set.PrismaCloudApp
    ]
    disable_on_destroy = true
    aws {
        name = var.pcs-cloud-acc-name
        account_id = var.account_id
        group_ids = [
            data.prismacloud_account_group.existing_account_group_id.group_id,
        ]
        role_arn = "arn:aws:iam::${var.account_id}:role/PcsIamRole" 
        //role_arn = aws_cloudformation_stack_set.PrismaCloudApp.outputs.PrismaCloudRoleARN

        features {
            name = "Agentless Scanning" 
            state = "enabled"
        }
    }
}