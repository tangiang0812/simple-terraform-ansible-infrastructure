terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "ConsoleUser"
  region  = "ap-southeast-1"
}

resource "aws_security_group" "allow_ssh" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "cloud_pem" {
  filename        = "${path.module}/app-server-key.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "app-server-key"
  public_key = tls_private_key.key.public_key_openssh
}


data "aws_ami" "debian_image" {
  executable_users = ["all"]
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["debian-12-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.debian_image.id
  instance_type = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  provisioner "remote-exec" {
    inline = [
      "echo Hello World",
      # "export MONGO_URI=mongodb+srv://gnaig:gnaig@cluster0.adtna.mongodb.net/?retryWrites=true&w=majority",
    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = tls_private_key.key.private_key_pem
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u admin --key-file app-server-key.pem -T 300 -i '${self.public_ip},' ./roles/app.yaml"
  }

  tags = {
    Name = "AppServerInstance"
  }
}
