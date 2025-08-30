resource "random_id" "unique_suffix" {
  byte_length = 4
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.prefix}-aurora-subnet-group-${random_id.unique_suffix.hex}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.prefix}-aurora-subnet-group"
    IAC  = "True"
  }
}

resource "aws_security_group" "aurora_sg" {
  name        = "${var.prefix}-aurora-sg"
  description = "Allow inbound traffic for Aurora"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-aurora-sg"
    IAC  = "True"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${var.prefix}-aurora-cluster-${random_id.unique_suffix.hex}"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "15.10"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  skip_final_snapshot     = true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
  }

  tags = {
    Name = "${var.prefix}-aurora-cluster"
    IAC  = "True"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "${var.prefix}-aurora-instance-${random_id.unique_suffix.hex}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true

  tags = {
    Name = "${var.prefix}-aurora-instance"
    IAC  = "True"
  }
}