terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.22.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
    workspace_dir = "workspace"
  }
}

provider "aws" {
  region = "us-west-2"
}
