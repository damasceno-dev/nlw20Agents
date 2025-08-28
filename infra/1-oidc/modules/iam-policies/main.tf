# ========================================
# GRANULAR IAM POLICIES FOR GITHUB OIDC
# ========================================
# These policies provide least-privilege access for each AWS service
# Based on the original 1-admin policies but adapted for OIDC

# ========================================
# VPC AND NETWORKING POLICY
# ========================================
resource "aws_iam_policy" "vpc_policy" {
  name        = "${var.prefix}-OIDC-VPCPolicy"
  description = "IAM policy for managing VPC resources via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeNetworkInterfaces",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-VPCPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# RDS AND AURORA POLICY
# ========================================
resource "aws_iam_policy" "rds_policy" {
  name        = "${var.prefix}-OIDC-RDSPolicy"
  description = "IAM policy for managing RDS and Aurora via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # RDS Instance permissions
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance",
          "rds:RebootDBInstance",
          "rds:StartDBInstance",
          "rds:StopDBInstance",

          # Aurora Cluster permissions (CRITICAL for Aurora Serverless v2)
          "rds:CreateDBCluster",
          "rds:DeleteDBCluster",
          "rds:DescribeDBClusters",
          "rds:ModifyDBCluster",
          "rds:StartDBCluster",
          "rds:StopDBCluster",
          "rds:DescribeDBClusterEndpoints",
          "rds:DescribeDBClusterParameters",
          "rds:DescribeDBClusterParameterGroups",
          "rds:CreateDBClusterParameterGroup",
          "rds:DeleteDBClusterParameterGroup",
          "rds:ModifyDBClusterParameterGroup",
          "rds:CreateDBClusterSnapshot",
          "rds:DeleteDBClusterSnapshot",
          "rds:DescribeDBClusterSnapshots",
          "rds:RestoreDBClusterFromSnapshot",
          "rds:ModifyCurrentDBClusterCapacity",
          
          # Global cluster permissions
          "rds:DescribeGlobalClusters",

          # Subnet groups
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:DescribeDBSubnetGroups",
          "rds:ModifyDBSubnetGroup",

          # Security and parameter groups
          "rds:DescribeDBSecurityGroups",
          "rds:CreateDBParameterGroup",
          "rds:DeleteDBParameterGroup",
          "rds:DescribeDBParameterGroups",
          "rds:ModifyDBParameterGroup",

          # Tags and metadata
          "rds:AddTagsToResource",
          "rds:ListTagsForResource",
          "rds:RemoveTagsFromResource",

          # Engine and options
          "rds:DescribeDBEngineVersions",
          "rds:DescribeOrderableDBInstanceOptions",
          "rds:DescribeEngineDefaultClusterParameters",
          "rds:DescribeEngineDefaultParameters"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-RDSPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# ECR POLICY
# ========================================
resource "aws_iam_policy" "ecr_policy" {
  name        = "${var.prefix}-OIDC-ECRPolicy"
  description = "IAM policy for managing Amazon ECR via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Repository management
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:UpdateRepository",

          # Image management
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchDeleteImage",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DeleteLifecyclePolicy",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:PutLifecyclePolicy",
          "ecr:StartImageScan",
          "ecr:StartLifecyclePolicyPreview",
          "ecr:UploadLayerPart",

          # Authentication
          "ecr:GetAuthorizationToken",

          # Repository policies
          "ecr:DeleteRepositoryPolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",

          # Registry policies
          "ecr:DeleteRegistryPolicy",
          "ecr:GetRegistryPolicy",
          "ecr:PutRegistryPolicy",

          # Tagging
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:UntagResource",

          # Public ECR (if needed)
          "ecr-public:CreateRepository",
          "ecr-public:DeleteRepository",
          "ecr-public:DescribeRepositories",
          "ecr-public:GetAuthorizationToken",
          "ecr-public:BatchCheckLayerAvailability",
          "ecr-public:PutImage"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-ECRPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# APP RUNNER POLICY
# ========================================
resource "aws_iam_policy" "app_runner_policy" {
  name        = "${var.prefix}-OIDC-AppRunnerPolicy"
  description = "IAM policy for managing AWS App Runner via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Service management
          "apprunner:CreateService",
          "apprunner:DeleteService",
          "apprunner:DescribeService",
          "apprunner:UpdateService",
          "apprunner:ListServices",
          "apprunner:PauseService",
          "apprunner:ResumeService",
          "apprunner:StartDeployment",

          # Configuration
          "apprunner:CreateAutoScalingConfiguration",
          "apprunner:DeleteAutoScalingConfiguration",
          "apprunner:DescribeAutoScalingConfiguration",
          "apprunner:ListAutoScalingConfigurations",
          "apprunner:UpdateDefaultAutoScalingConfiguration",

          # Observability
          "apprunner:CreateObservabilityConfiguration",
          "apprunner:DeleteObservabilityConfiguration",
          "apprunner:DescribeObservabilityConfiguration",
          "apprunner:ListObservabilityConfigurations",

          # VPC
          "apprunner:CreateVpcConnector",
          "apprunner:DeleteVpcConnector",
          "apprunner:DescribeVpcConnector",
          "apprunner:ListVpcConnectors",

          # Operations and connections
          "apprunner:ListOperations",
          "apprunner:DescribeOperation",
          "apprunner:CreateConnection",
          "apprunner:DeleteConnection",
          "apprunner:ListConnections",

          # Tagging
          "apprunner:ListTagsForResource",
          "apprunner:TagResource",
          "apprunner:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-AppRunnerPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# IAM POLICY (FOR SERVICE ROLES)
# ========================================
resource "aws_iam_policy" "iam_policy" {
  name        = "${var.prefix}-OIDC-IAMPolicy"
  description = "IAM policy for managing IAM roles and policies via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Role management
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:UpdateRole",
          "iam:PassRole",
          "iam:UpdateAssumeRolePolicy",

          # Role policies
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",

          # Policy management
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicies",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion",

          # Instance profiles
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:ListInstanceProfilesForRole",

          # Service-linked roles
          "iam:CreateServiceLinkedRole",
          "iam:DeleteServiceLinkedRole",
          "iam:GetServiceLinkedRoleDeletionStatus",

          # Tags
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRoleTags",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:ListPolicyTags"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-IAMPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# S3 POLICY
# ========================================
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.prefix}-OIDC-S3Policy"
  description = "IAM policy for managing S3 buckets via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = "arn:aws:s3:::${var.prefix}-terraform-state-unique1029"
      },
      {
        Sid    = "TerraformStateObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.prefix}-terraform-state-unique1029/*"
      },
      {
        Sid    = "ApplicationBuckets"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetBucketAcl",
          "s3:PutBucketAcl",
          "s3:GetBucketCORS",
          "s3:PutBucketCORS",
          "s3:GetBucketWebsite",
          "s3:PutBucketWebsite",
          "s3:DeleteBucketWebsite",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketEncryption",
          "s3:PutBucketEncryption",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging"
        ]
        Resource = "arn:aws:s3:::${var.prefix}-*"
      },
      {
        Sid    = "ApplicationBucketObjects"
        Effect = "Allow"
        Action = "s3:*"
        Resource = "arn:aws:s3:::${var.prefix}-*/*"
      },
      {
        Sid    = "ListAllBuckets"
        Effect = "Allow"
        Action = "s3:ListAllMyBuckets"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-S3Policy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# CLOUDWATCH LOGS POLICY
# ========================================
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.prefix}-OIDC-CloudWatchPolicy"
  description = "IAM policy for CloudWatch Logs via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Log groups
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "logs:TagLogGroup",
          "logs:UntagLogGroup",

          # Log streams
          "logs:CreateLogStream",
          "logs:DeleteLogStream",
          "logs:DescribeLogStreams",

          # Log events
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",

          # Retention
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",

          # Metric filters
          "logs:PutMetricFilter",
          "logs:DeleteMetricFilter",
          "logs:DescribeMetricFilters",

          # Subscription filters
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter",
          "logs:DescribeSubscriptionFilters",

          # Insights
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:DescribeQueries"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-CloudWatchPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# SQS POLICY
# ========================================
resource "aws_iam_policy" "sqs_policy" {
  name        = "${var.prefix}-OIDC-SQSPolicy"
  description = "IAM policy for managing SQS queues via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Queue management
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:ListDeadLetterSourceQueues",

          # Queue attributes
          "sqs:GetQueueAttributes",
          "sqs:SetQueueAttributes",

          # Message operations
          "sqs:SendMessage",
          "sqs:SendMessageBatch",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:DeleteMessageBatch",
          "sqs:ChangeMessageVisibility",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:PurgeQueue",

          # Permissions
          "sqs:AddPermission",
          "sqs:RemovePermission",

          # Tags
          "sqs:ListQueueTags",
          "sqs:TagQueue",
          "sqs:UntagQueue"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-SQSPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}

# ========================================
# AMPLIFY POLICY
# ========================================
resource "aws_iam_policy" "amplify_policy" {
  name        = "${var.prefix}-OIDC-AmplifyPolicy"
  description = "IAM policy for managing AWS Amplify via GitHub OIDC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Amplify App management
          "amplify:CreateApp",
          "amplify:DeleteApp",
          "amplify:GetApp",
          "amplify:ListApps",
          "amplify:UpdateApp",
          
          # Branch management
          "amplify:CreateBranch",
          "amplify:DeleteBranch",
          "amplify:GetBranch",
          "amplify:ListBranches",
          "amplify:UpdateBranch",
          
          # Domain management
          "amplify:CreateDomainAssociation",
          "amplify:DeleteDomainAssociation",
          "amplify:GetDomainAssociation",
          "amplify:ListDomainAssociations",
          "amplify:UpdateDomainAssociation",
          
          # Build and deployment
          "amplify:StartJob",
          "amplify:StopJob",
          "amplify:GetJob",
          "amplify:ListJobs",
          
          # Webhook management
          "amplify:CreateWebhook",
          "amplify:DeleteWebhook",
          "amplify:GetWebhook",
          "amplify:ListWebhooks",
          "amplify:UpdateWebhook",
          
          # Backend environment
          "amplify:CreateBackendEnvironment",
          "amplify:DeleteBackendEnvironment",
          "amplify:GetBackendEnvironment",
          "amplify:ListBackendEnvironments",
          "amplify:UpdateBackendEnvironment",
          
          # Tagging
          "amplify:ListTagsForResource",
          "amplify:TagResource",
          "amplify:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.prefix}-OIDC-AmplifyPolicy"
    Project = var.prefix
    IAC     = "True"
  }
}