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
resource "aws_key_pair" "ec2_key" {
  key_name   = "data-key-pair"
  public_key = var.sshpublickey
}

# Data reference for SSM parameter pointing to Win server image
data "aws_ssm_parameter" "win-serv-ami-latest" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

# # Data reference for SSM parameter pointing to Win server image with applications preinstalled (requires manual manipulation)
# data "aws_ssm_parameter" "win-serv-ami-prebuilt" {
#   name = "/winserv2022/prebuilt/Windows_Server-2022-English-Full-Base"
# }

# EC2 instance to host the prod data server
# resource "aws_launch_template" "prod_server_launch_configuration" {
#   name = "dataserver_launch_configuration"
#   image_id = data.aws_ssm_parameter.win-serv-ami-latest.value
#   instance_type = var.instance_type
#   user_data = base64encode(file("${path.module}/user_data/ec2_prod_data.tpl"))
#   key_name = aws_key_pair.ec2_key.key_name

#   iam_instance_profile {
#     arn  = aws_iam_instance_profile.ec2_web_profile.arn
#   }
#   network_interfaces {
#     subnet_id     = aws_subnet.compute_zonea.id
#     associate_public_ip_address = true
#     security_groups = [ aws_security_group.ec2-sg.id ]
#   }  
# }

# EC2 instance to host the dev data server 
resource "aws_launch_template" "dev_server_launch_configuration" {
  name = "dataserver_launch_configuration"
  image_id = data.aws_ssm_parameter.win-serv-ami-latest.value
  instance_type = var.instance_type
  user_data = base64encode(file("${path.module}/user_data/ec2_dev_data.tpl"))
  key_name = aws_key_pair.ec2_key.key_name

  iam_instance_profile {
    arn  = aws_iam_instance_profile.ec2_data_profile.arn
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
  instance_type               = var.instance_type
  user_data                   = base64encode(templatefile("${path.module}/user_data/ec2_prod_data.tftpl", { gitpath = "git/${each.value.Name}" }))
  key_name                    = aws_key_pair.ec2_key.key_name
  subnet_id                   = aws_subnet.compute_zoneb.id
  associate_public_ip_address = true
  hibernation                 = true

  iam_instance_profile = aws_iam_instance_profile.ec2_data_profile.name
  security_groups      = [ aws_security_group.ec2-sg.id ]

  root_block_device {
    encrypted = true
    volume_size = 30
    volume_type = "gp3"
  }
 
  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "${each.value.Name}",
      "Group" = "autoexecutedaily",
    })
  )}"
  depends_on = [ aws_ssm_parameter.GitConnectionString ]
}

resource "aws_instance" "dev_instance" {  
  launch_template { 
    id = aws_launch_template.dev_server_launch_configuration.id
  }
  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "devdataserver",
      "Group" = "autoexecutedaily",
    })
  )}"
}