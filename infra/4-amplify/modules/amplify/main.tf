# IAM role for Amplify
resource "aws_iam_role" "amplify_role" {
  name = "${var.prefix}-amplify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-amplify-role"
    Project = var.prefix
  }
}

# IAM policy for Amplify service
resource "aws_iam_policy" "amplify_policy" {
  name        = "${var.prefix}-amplify-policy"
  description = "IAM policy for Amplify service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-amplify-policy"
    Project = var.prefix
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "amplify_policy_attachment" {
  role       = aws_iam_role.amplify_role.name
  policy_arn = aws_iam_policy.amplify_policy.arn
}

# Amplify App
resource "aws_amplify_app" "main" {
  name         = "${var.prefix}-web-app"
  description  = "Next.js frontend with API integration - Simple Routing ${formatdate("YYYY-MM-DD hh:mm:ss", timestamp())}"
  repository   = var.github_repository
  access_token = var.github_access_token
  
  # Environment variables
  environment_variables = var.environment_variables

  # Enable auto branch creation and deployment
  enable_auto_branch_creation = false
  enable_branch_auto_build    = true
  enable_branch_auto_deletion = false

  # Platform
  platform = "WEB_COMPUTE"

  # IAM role
  iam_service_role_arn = aws_iam_role.amplify_role.arn

  # Build spec inline for better control
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - cd web
            - nvm use 20
            - npm ci --include=dev
            - |
              if [ -n "$SWAGGER_URL" ]; then
                curl -f -s "$SWAGGER_URL" > /dev/null && npm run generate-api:prod || echo "Swagger not accessible"
              fi
        build:
          commands:
            - npm run build:amplify
            # Debug: Check what files are created
            - ls -la
            - ls -la .next || echo "No .next directory"
            - ls -la .amplify-hosting || echo "No .amplify-hosting directory"
            - ls -la .amplify-hosting/compute/default || echo "No compute/default directory"
            - find . -name "deploy-manifest.json" -type f || echo "No deploy-manifest.json found"
            - cat .amplify-hosting/deploy-manifest.json || echo "Could not read deploy-manifest.json"
      artifacts:
        baseDirectory: web/.amplify-hosting
        files:
          - '**/*'
      cache:
        paths:
          - web/node_modules/**/*
  EOT

  tags = {
    Name        = "${var.prefix}-web-app"
    Project     = var.prefix
    Environment = "production"
    BuildSpec   = "v14-simple-routing-${formatdate("YYYYMMDD-hhmm", timestamp())}" # Force rebuild with timestamp
  }
}

# Amplify Branch (main branch)
resource "aws_amplify_branch" "main" {
  count           = var.github_repository != "" ? 1 : 0
  app_id          = aws_amplify_app.main.id
  branch_name     = var.branch_name
  enable_auto_build = true

  # Environment variables for this specific branch
  environment_variables = var.environment_variables

  tags = {
    Name        = "${var.prefix}-${var.branch_name}-branch"
    Project     = var.prefix
    Environment = "production"
  }
}

# Trigger initial deployment
resource "null_resource" "trigger_deployment" {
  count = var.github_repository != "" ? 1 : 0
  
  depends_on = [aws_amplify_branch.main]
  
  provisioner "local-exec" {
    command = <<-EOT
      aws amplify start-job \
        --app-id ${aws_amplify_app.main.id} \
        --branch-name ${var.branch_name} \
        --job-type RELEASE \
        --region us-east-1
    EOT
  }

  triggers = {
    app_id = aws_amplify_app.main.id
    branch = var.branch_name
  }
}