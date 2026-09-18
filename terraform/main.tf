terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-ansible-key"
  public_key = file(pathexpand("~/.ssh/terraform-ansible-key.pub"))
}

resource "aws_security_group" "web_sg" {
  name        = "static-website-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  tags = {
    Name = "Terraform-Ansible-Web"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    web_servers = [
      {
        name       = aws_instance.web.tags.Name
        public_ip  = aws_instance.web.public_ip
        private_ip = aws_instance.web.private_ip
      }
    ]
    ssh_private_key_path = pathexpand(var.ssh_private_key_path)
  })

  filename   = "${path.module}/../ansible/inventory"
  depends_on = [aws_instance.web]
}
