resource "aws_vpc" "redshift_vpc" {

  cidr_block = "10.0.0.0/16"

  instance_tenancy = "default"

  tags = {

    Name = "redshift-vpc"

  }

}

resource "aws_internet_gateway" "redshift_vpc_gw" {

  vpc_id = aws_vpc.redshift_vpc.id

  depends_on = [

    aws_vpc.redshift_vpc

  ]

}

resource "aws_default_security_group" "redshift_security_group" {

  vpc_id = aws_vpc.redshift_vpc.id

  ingress {

    from_port = 5439

    to_port = 5439

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {

    Name = "redshift-sg"

  }

  depends_on = [

    aws_vpc.redshift_vpc

  ]

}

resource "aws_subnet" "redshift_subnet_1" {

  vpc_id = aws_vpc.redshift_vpc.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = "true"

  tags = {

    Name = "redshift-subnet-1"

  }

  depends_on = [

    aws_vpc.redshift_vpc

  ]

}

resource "aws_subnet" "redshift_subnet_2" {

  vpc_id = aws_vpc.redshift_vpc.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = "true"

  tags = {

    Name = "redshift-subnet-2"

  }

  depends_on = [

    aws_vpc.redshift_vpc

  ]

}


resource "aws_redshift_subnet_group" "redshift_subnet_group" {

  name = "redshift-subnet-group"

  subnet_ids = ["${aws_subnet.redshift_subnet_1.id}",

  "${aws_subnet.redshift_subnet_2.id}"]

  tags = {

    environment = "dev"

    Name = "redshift-subnet-group"

  }

}


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


resource "aws_redshift_cluster" "redshift-cluster-1" {
  cluster_identifier        = "redshift-cluster-1"
  database_name             = "dev"
  iam_roles                 = [aws_iam_role.redshift_etl_role.arn, ]
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  skip_final_snapshot       = true
  master_password           = var.REDSHIFT_CLUSTER_1_PASS
  master_username           = "awsuser"
  port                      = 5439
  publicly_accessible       = true
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.id
  depends_on = [

    aws_vpc.redshift_vpc,

    aws_default_security_group.redshift_security_group,

    aws_redshift_subnet_group.redshift_subnet_group,

    aws_iam_role.redshift_etl_role

  ]

}
