resource "aws_security_group" "ecs_security_Group" {
  name = "aws_batch_compute_environment_security_group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "ecs_subnet" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = "10.1.1.0/24"
}