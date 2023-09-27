resource "aws_iam_role" "redshift_etl_role" {
  name = "redshift_etl_role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow",
        Sid    = ""
        Principal = {
          Service : "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = "Redshift ETL Role"
    Program = "Udacity Data Engineering Nanodegree"
  }
}


resource "aws_iam_role_policy_attachment" "redshift_etl_s3_read_only" {
  role       = aws_iam_role.redshift_etl_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "redshift_etl_redshift_full_access" {
  role       = aws_iam_role.redshift_etl_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
