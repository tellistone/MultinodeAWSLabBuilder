output "vpc_id" {
  value = aws_vpc.Website_Default.id
}

output "security_group_id" {
  value = aws_security_group.inbound_ssh_and_http.id
}