variable "pcs-url" {
  type = string
}

variable "pcs-username" {
  type = string
}

variable "pcs-password" {
  type = string
}

/*
variable "pcs-tenant" {
  type = string
}
*/

variable "pcs-account-grp-name" {
  type = string
  default = "Default Account Group"
}

variable "pcs-aws-mgmt-account-id" {
  type = string
}

variable "pcs-aws-iam-org-stack-name" {
  type = string
}

variable "pcs-aws-iam-org-stack-root-ou-id" {
  type = string
}

variable "pcs-aws-iam-org-stack-iam-role-name" {
  type = string
}

variable "pcs-cloud-acc-name" {
  type = string
}
