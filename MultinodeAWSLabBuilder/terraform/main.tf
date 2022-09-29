#Call the Module which creates our VPC and Subnet.
module "vpc_subnet" {
  source = "../terraform/modules/vpc_subnet"
}

#Provision an EC2 Key Pair for our instance and the correct credentials for SSM to work.
module "security" {
  source = "../terraform/modules/security"
}

#Create an S3 Bucket that we can use to store the public key so we never lose it.
module "s3" {
  source     = "../terraform/modules/S3"
  public_key = module.security.instance_ssh_public_key
}

#Creation of Compute infrastructure (EC2).
module "compute" {
  source = "../terraform/modules/compute"


  security_group_id    = module.vpc_subnet.security_group_id
  ssh_key              = module.security.instance_ssh_key_name
  aws_instance_profile = module.security.aws_instance_profile
  vpc_id               = module.vpc_subnet.vpc_id

  depends_on = [module.vpc_subnet, module.security]

}