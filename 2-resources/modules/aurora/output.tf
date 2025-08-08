output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
  description = "Writer endpoint for the Aurora cluster"
}

output "aurora_reader_endpoint" {
  value = aws_rds_cluster.aurora_cluster.reader_endpoint
  description = "Reader endpoint for the Aurora cluster"
}

output "aurora_security_group_id" {
  value = aws_security_group.aurora_sg.id
}