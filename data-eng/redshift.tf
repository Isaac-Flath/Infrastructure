resource "aws_iam_role" "myRedshiftRole2" {
  name = "myRedshiftRole2"

  assume_role_policy = jsonencode({

    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_etl_s3_read_only2" {
  role       = aws_iam_role.myRedshiftRole2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_security_group" "redshift_security_group2" {
  name   = "redshift_security_group2"
  vpc_id = "vpc-63e47f19" # Select this default VPC automatically?

  ingress {
    description = "Allow traffic from anywhere"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_user" "test-conupdate-31392" {
  name = "test-conupdate-31392"
  # May need to programatically create access key
}

resource "aws_iam_user_policy_attachment" "s3attach1" {
  user       = aws_iam_user.test-conupdate-31392.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

}
resource "aws_iam_user_policy_attachment" "s3attach2" {
  user       = aws_iam_user.test-conupdate-31392.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_redshift_cluster" "redshift-cluster-2" {
  cluster_identifier     = "redshift-cluster-2"
  database_name          = "dev"
  iam_roles              = [aws_iam_role.myRedshiftRole2.arn, ]
  node_type              = "dc2.large"
  cluster_type           = "single-node"
  skip_final_snapshot    = true
  master_password        = var.REDSHIFT_CLUSTER_1_PASS
  master_username        = "awsuser"
  port                   = 5439
  publicly_accessible    = true
  enhanced_vpc_routing   = false
  vpc_security_group_ids = [aws_security_group.redshift_security_group2.id, ]
  depends_on = [

    aws_security_group.redshift_security_group2,
    aws_iam_role.myRedshiftRole2,

  ]

}
