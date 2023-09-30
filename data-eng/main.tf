terraform {
  cloud {
    organization = "isaac-flath"
    workspaces {
      name = "tfc-aws-data-eng"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "udacitydataengineeringaws" {
  bucket = "udacitydataengineeringaws"

  tags = {
    Name    = "Udacity Data Engineering Nanodegree"
    Program = "Udacity Data Engineering Nanodegree"
  }
}

