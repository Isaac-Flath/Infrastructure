resource "aws_iam_role" "RedshiftRole" {
  name = "RedshiftRole"

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

resource "aws_iam_role_policy_attachment" "redshift_etl_s3_read_only" {
  role       = aws_iam_role.RedshiftRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_security_group" "redshift_security_group" {
  name   = "redshift_security_group"
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

resource "aws_iam_user" "Redshift-ETL-user" {
  name = "Redshift-ETL-user"
  # May need to programatically create access key
}

resource "aws_iam_user_policy_attachment" "Reshift-ETL-User-S3-Attach" {
  user       = aws_iam_user.Redshift-ETL-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

}
resource "aws_iam_user_policy_attachment" "Reshift-ETL-User-RS-Attach" {
  user       = aws_iam_user.Redshift-ETL-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_redshift_cluster" "redshift-cluster-1" {
  cluster_identifier     = "redshift-cluster-1"
  database_name          = "dev"
  iam_roles              = [aws_iam_role.RedshiftRole.arn, ]
  node_type              = "dc2.large"
  cluster_type           = "single-node"
  skip_final_snapshot    = true
  master_password        = var.REDSHIFT_CLUSTER_1_PASS
  master_username        = "awsuser"
  port                   = 5439
  publicly_accessible    = true
  enhanced_vpc_routing   = false
  vpc_security_group_ids = [aws_security_group.redshift_security_group.id, ]
  depends_on = [

    aws_security_group.redshift_security_group,
    aws_iam_role.RedshiftRole,

  ]

}
