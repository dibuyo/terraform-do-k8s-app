terraform {
    required_providers {
    
        kubernetes = {
            source = "hashicorp/kubernetes"
        }

        kubernetes-alpha = "~> 0.2.1"
        
        digitalocean = {
            source = "digitalocean/digitalocean"
        }

        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}