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
  repository   = var.github_repository
  access_token = var.github_access_token

  # Build settings for Next.js with orval API generation
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
            # Generate API client from backend swagger if URL is available
            - |
              if [ -n "$SWAGGER_URL" ] && [ "$SWAGGER_URL" != "" ]; then
                echo "Generating API client from: $SWAGGER_URL"
                npm run generate-api:prod
              else
                echo "No SWAGGER_URL provided, skipping API generation"
              fi
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

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

  # Custom rules for SPA routing
  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  tags = {
    Name        = "${var.prefix}-web-app"
    Project     = var.prefix
    Environment = "production"
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