data "aws_subnet_ids" "this" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Public"
  }
}


#Get AMI ID
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  owners = ["amazon", "self", "aws-marketplace"]

}

#Provision an ALB
resource "aws_lb" "this" {
  name               = "graylog-load-balancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.this.ids

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_launch_configuration" "Graylog" {
  name                        = "Graylog LC"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install_apache.sh")
  security_groups             = [var.security_group_id]
  key_name                    = var.ssh_key
  iam_instance_profile        = var.aws_instance_profile
  image_id                    = data.aws_ami.ubuntu.id
}

resource "aws_autoscaling_group" "Graylog_asg" {
  name                 = "Graylog"
  launch_configuration = aws_launch_configuration.Graylog.id
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = data.aws_subnet_ids.this.ids
}

resource "aws_autoscaling_attachment" "target" {
  autoscaling_group_name = aws_autoscaling_group.Graylog_asg.name
  alb_target_group_arn   = aws_lb_target_group.this.arn
}