terraform {
  required_version = ">= 0.12"
}

variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "prefix" {
  type    = string
  default = ""
}

variable "jumpbox_instance_type" {
  type    = string
  default = "t3.micro"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_key_pair" "jumpbox" {
  key_name   = "${var.prefix}-jumpbox"
  public_key = tls_private_key.jumpbox.public_key_openssh
}

resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

locals {
  public_cidr  = cidrsubnet(var.vpc_cidr, 6, 1)
  private_cidr = cidrsubnet(var.vpc_cidr, 6, 2)
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(local.public_cidr, 2, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.prefix}-public-${count.index}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-public-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "jumpbox" {
  name   = "${var.prefix}-jumpbox"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.jumpbox.id
}

resource "aws_security_group_rule" "ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.jumpbox.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "jumpbox" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.jumpbox_instance_type
  subnet_id                   = aws_subnet.public[0].id
  availability_zone           = var.availability_zones[0]
  key_name                    = aws_key_pair.jumpbox.key_name
  vpc_security_group_ids      = [aws_security_group.jumpbox.id]
  associate_public_ip_address = true

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 100
  }

  tags = {
    Name = "${var.prefix}-jumpbox"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "sudo mkdir /share",
      "sudo chown ubuntu:ubuntu /share",
      "echo \"${tls_private_key.jumpbox.private_key_pem}\" > /home/ubuntu/jumpbox.pem",
      "chmod 600 /home/ubuntu/jumpbox.pem",
    ]

    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jumpbox.private_key_pem
    }
  }

  #  provisioner "remote-exec" {
  #    script = "provision.sh"
  #
  #    connection {
  #      host        = coalesce(self.public_ip, self.private_ip)
  #      type        = "ssh"
  #      user        = "ubuntu"
  #      private_key = tls_private_key.jumpbox.private_key_pem
  #    }
  #  }

  provisioner "file" {
    source      = "terraform.tfstate"
    destination = "/home/ubuntu/terraform.tfstate"

    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jumpbox.private_key_pem
    }
  }

  provisioner "file" {
    source      = "terraform.tfvars"
    destination = "/home/ubuntu/terraform.tfvars"

    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jumpbox.private_key_pem
    }
  }

  provisioner "file" {
    source      = "provision.sh"
    destination = "/home/ubuntu/provision.sh"

    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jumpbox.private_key_pem
    }
  }
}

resource "aws_eip" "jumpbox" {
  instance = aws_instance.jumpbox.id
  vpc      = true
}

output "jumpbox_public_ip" {
  value = aws_eip.jumpbox.public_ip
}

output "jumpbox_ssh_public_key" {
  value = tls_private_key.jumpbox.public_key_pem
}

output "jumpbox_ssh_private_key" {
  value = tls_private_key.jumpbox.private_key_pem
}