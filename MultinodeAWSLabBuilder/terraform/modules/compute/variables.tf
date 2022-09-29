variable "region" {
  default     = "eu-west-2"
  type        = string
  description = "Region this Infrastructure is based in"
}

variable "vpc_id" {}
variable "security_group_id" {}
variable "ssh_key" {}
variable "aws_instance_profile" {}