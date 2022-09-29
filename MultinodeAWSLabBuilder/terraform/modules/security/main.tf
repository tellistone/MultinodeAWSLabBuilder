#Upload our local key to the Key store in AWS.
resource "aws_key_pair" "terraform-demo" {
  key_name   = "graylog-demo"
  public_key = file("${path.module}/keys/id_rsa.pub")
}

#Create an IAM Imstance Profile
resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.ssm-role.name
}

#Create an IAM role which has the correct privileges to use SSM
resource "aws_iam_role" "ssm-role" {
  name               = "ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
}

#Attach the role to our policy.
resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}