output "instance_ssh_public_key" {
  value = aws_key_pair.terraform-demo.public_key
}

output "instance_ssh_key_name" {
  value = aws_key_pair.terraform-demo.key_name
}

output "aws_instance_profile" {
  value = aws_iam_instance_profile.dev-resources-iam-profile.name
}