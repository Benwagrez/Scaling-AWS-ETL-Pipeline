# ========================= #
# ==== EC2 Web Server ===== #
# ========================= #
# Purpose
# Creating Auto Scaling Group with Linux VM for the webserver

# Setting terraform providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

# Data reference for existing public key
resource "aws_key_pair" "prod_ec2_key" {
  key_name   = "prod-data-key-pair"
  public_key = var.prod_ssh_public_key
}

resource "aws_key_pair" "dev_ec2_key" {
  key_name   = "dev-data-key-pair"
  public_key = var.dev_ssh_public_key
}

# Data reference for SSM parameter pointing to Win server image
data "aws_ssm_parameter" "win-serv-ami-latest" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

# EC2 instance to host the dev data server 
resource "aws_launch_template" "dev_server_launch_configuration" {
  name = "dataserver_launch_configuration"
  image_id = data.aws_ssm_parameter.win-serv-ami-latest.value
  instance_type = var.dev_instance_type
  user_data = base64encode(file("${path.module}/user_data/ec2_dev_data.tpl"))
  key_name = aws_key_pair.dev_ec2_key.key_name

  iam_instance_profile {
    arn  = aws_iam_instance_profile.ec2_dev_data_profile.arn
  }
  network_interfaces {
    subnet_id     = aws_subnet.compute_zoneb.id
    associate_public_ip_address = true
    security_groups = [ aws_security_group.ec2-sg.id ]
  } 
}

resource "aws_instance" "prod_instance" { 
  for_each   = {
    for index, client in var.prod_clients:
    client.Name => client
  }

  ami                         = data.aws_ssm_parameter.win-serv-ami-latest.value
  instance_type               = var.prod_instance_type
  user_data                   = base64encode(templatefile("${path.module}/user_data/ec2_prod_data.tftpl", { gitpath = "/git/${each.value.Name}" }))
  key_name                    = aws_key_pair.prod_ec2_key.key_name
  subnet_id                   = aws_subnet.compute_zoneb.id
  associate_public_ip_address = true
  hibernation                 = true

  iam_instance_profile = aws_iam_instance_profile.ec2_data_profile[each.value.Name].name
  security_groups      = [ aws_security_group.ec2-sg.id ]

  root_block_device {
    encrypted = true
    volume_size = 30
    volume_type = "gp3"
  }
 
  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "${each.value.Name} Prod Data Analytics Server",
      "Group" = "autoexecutedaily",
      "UUID" = "${base64encode(each.value.Name)}",
    })
  )}"
  depends_on = [ aws_ssm_parameter.GitConnectionString ]
}

# resource "aws_instance" "dev_instance" {  
#   launch_template { 
#     id = aws_launch_template.dev_server_launch_configuration.id
#   }
#   tags = "${merge(
#     var.common_tags,
#     tomap({
#       "Name" = "Dev Data Analytics Server",
#       "Group" = "devservers",
#     })
#   )}"
# }