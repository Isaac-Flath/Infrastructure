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

resource "aws_redshift_cluster" "redshift-cluster-1" {
  cluster_identifier  = "redshift-cluster-1"
  database_name       = "dev"
  iam_roles           = [aws_iam_role.redshift_etl_role.arn, ]
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  skip_final_snapshot = true
  master_password     = var.REDSHIFT_CLUSTER_1_PASS
  master_username     = "awsuser"
  port                = 5439
}


# resource "aws_db_instance" "default" {
#   allocated_storage   = 10
#   db_name             = "postgres-1"
#   engine              = "postgres"
#   instance_class      = "db.t3.micro"
#   username            = "awsuser"
#   password            = var.REDSHIFT_CLUSTER_1_PASS
#   skip_final_snapshot = true
# }

