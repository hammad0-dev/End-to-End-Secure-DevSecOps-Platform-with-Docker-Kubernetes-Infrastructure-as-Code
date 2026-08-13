# Root module — wires the per-env stacks together. This file is intentionally
# small; concrete env config lives in environments/{dev,prod}.

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.32" }
    helm       = { source = "hashicorp/helm", version = "~> 2.14" }
    vault      = { source = "hashicorp/vault", version = "~> 4.4" }
    kafka      = { source = "Mongey/kafka", version = "~> 0.7" }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_security_group" "allow_all_ssh" {
  name        = "allow_all_ssh"
  description = "Security group that allows SSH from anywhere"
  
  # VULNERABILITY: Ingress open to 0.0.0.0/0
  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
