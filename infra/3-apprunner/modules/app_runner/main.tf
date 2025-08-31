resource "aws_iam_role" "app_runner_auth_role" {
  name = "${var.prefix}-AppRunnerAuthRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "build.apprunner.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role" "app_runner_instance_role" {
  name = "${var.prefix}-AppRunnerInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "tasks.apprunner.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "app_runner_policy" {
  name        = "${var.prefix}-AppRunnerServicePolicy"
  description = "Policy for AWS App Runner to access ECR, replicating the AWS managed policy"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_auth_policy_attach" {
  role       = aws_iam_role.app_runner_auth_role.name
  policy_arn = aws_iam_policy.app_runner_policy.arn
}

resource "aws_apprunner_service" "app" {
  service_name = "${var.prefix}-app-runner"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_auth_role.arn
    }

    image_repository {
      image_identifier      = "${var.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"
        # Environment variables are managed by the null_resource below
        runtime_environment_variables = {}
      }
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
    instance_role_arn = aws_iam_role.app_runner_instance_role.arn
  }

  observability_configuration {
    observability_enabled = false
  }

  tags = {
    Name = "${var.prefix}-app-runner"
    IAC  = "True"
  }

  # CORS will be managed by the null_resource below with proper timing
}

# Separate resource to handle CORS configuration with proper timing
resource "null_resource" "cors_configuration" {
  count = var.configure_cors && var.amplify_url != "" ? 1 : 0

  depends_on = [aws_apprunner_service.app]

  triggers = {
    amplify_url = var.amplify_url
    service_id  = aws_apprunner_service.app.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for App Runner service to be ready..."
      sleep 30

      # Wait for service to be in RUNNING state
      for i in {1..60}; do
        STATUS=$(aws apprunner describe-service --service-arn ${aws_apprunner_service.app.arn} --region us-east-1 --query 'Service.Status' --output text 2>/dev/null)
        if [ "$STATUS" = "RUNNING" ]; then
          echo "✅ Service is running, configuring CORS..."
          break
        elif [ "$STATUS" = "OPERATION_IN_PROGRESS" ]; then
          echo "⏳ Service operation in progress, waiting..."
          sleep 20
        else
          echo "⚠️ Service status: $STATUS, retrying..."
          sleep 10
        fi
      done

      if [ "$STATUS" = "RUNNING" ]; then
        echo "🎯 Updating CORS configuration..."
        aws apprunner update-service \
          --service-arn ${aws_apprunner_service.app.arn} \
          --region us-east-1 \
          --source-configuration '{
            "ImageRepository": {
              "ImageIdentifier": "${var.repository_url}:latest",
              "ImageRepositoryType": "ECR",
              "ImageConfiguration": {
                "Port": "8080",
                "RuntimeEnvironmentVariables": {
                  "Cors__AllowedOrigins": "https://${var.amplify_url}"
                }
              }
            }
          }' || echo "⚠️ CORS update failed, will retry on next deployment"
      else
        echo "⚠️ Service didn't reach RUNNING state, skipping CORS configuration"
      fi
    EOT
  }
}