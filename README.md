# CI/CD Setup Guide for Monorepo

## Overview
This guide walks you through setting up the unified CI/CD pipeline for your monorepo containing infrastructure, server, and web components.

## Architecture
```
nlw20Agents/
├── .github/
│   └── workflows/
│       ├── deploy-full-stack.yml    # Main deployment workflow
│       ├── deploy-on-change.yml     # Component-specific deployment
│       └── destroy-full-stack.yml   # Teardown workflow
├── infra/                           # AWS Infrastructure (Terraform)
├── server/                          # .NET Backend API
├── web/                            # Next.js Frontend
└── .secrets.unified.example        # Secrets template
```

## Initial AWS Setup Requirements

Before running any Terraform or CI/CD workflows, you must complete these **manual setup steps**:

### 1. Create S3 Bucket for Terraform State
You must manually create an S3 bucket to store Terraform state files. This bucket is NOT managed by Terraform.

```bash
# Bucket naming convention: {prefix}-terraform-state-unique1029
# Example: If your prefix is "agents", create:
# Bucket name: agents-terraform-state-unique1029
# Region: us-east-1
```

**Important**: 
- Create this bucket through AWS Console, NOT through Terraform
- Enable versioning for state file protection
- Enable encryption for security
- This bucket must exist before running any Terraform commands

### 2. Configure IAM Permissions for Admin User

The user executing the Terraform scripts needs specific IAM permissions. Create a custom IAM policy with the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicies",
        "iam:ListPolicyVersions",
        "iam:CreatePolicyVersion",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAttachedUserPolicies",
        "iam:AttachGroupPolicy",
        "iam:DetachGroupPolicy",
        "iam:ListAttachedGroupPolicies",
        "iam:DeletePolicyVersion"
      ],
      "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:policy/${prefix}-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAttachedUserPolicies",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup",
        "iam:ListGroupsForUser"
      ],
      "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:user/${resources_creator_profile}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateGroup",
        "iam:DeleteGroup",
        "iam:GetGroup",
        "iam:ListGroups",
        "iam:ListGroupPolicies",
        "iam:AttachGroupPolicy",
        "iam:DetachGroupPolicy",
        "iam:PutGroupPolicy",
        "iam:ListAttachedGroupPolicies",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:group/${prefix}-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
      ],
      "Resource": [
        "arn:aws:s3:::${prefix}-terraform-state-unique1029",
        "arn:aws:s3:::${prefix}-terraform-state-unique1029/*"
      ]
    }
  ]
}
```

**How to apply this policy:**
1. Replace `YOUR_ACCOUNT_ID` with your AWS account ID
2. Replace `${prefix}` with your project prefix (e.g., "agents")
3. Replace `${resources_creator_profile}` with your resources creator username
4. Go to AWS IAM → Policies → Create Policy
5. Choose JSON editor and paste the modified policy
6. Name it something like `{prefix}-admin-terraform-policy`
7. Attach this policy to your admin IAM user

### 3. Create IAM Users

You'll need two IAM users:
1. **Admin User**: For Terraform infrastructure management (with the policy above)
2. **Resources Creator User**: For deploying application resources (will be configured by Terraform)

## Estimated AWS Costs (as of August 2025)

Based on the infrastructure defined in Terraform, here are the estimated monthly costs for a typical deployment:

### Infrastructure Components & Costs

| Service | Configuration | Estimated Monthly Cost |
|---------|--------------|----------------------|
| **Aurora Serverless v2** | - PostgreSQL<br>- 0.5 ACU minimum<br>- 1 ACU maximum<br>- Multi-AZ disabled | ~$45-90/month |
| **App Runner** | - 0.25 vCPU<br>- 0.5 GB memory<br>- Auto-scaling 1-10 instances | ~$5-50/month<br>(depends on traffic) |
| **ECR** | - Docker image storage<br>- ~1-2 GB images | ~$0.10/month |
| **VPC** | - 2 public subnets<br>- 2 private subnets<br>- 1 NAT Gateway | ~$45/month |
| **S3** | - Terraform state storage<br>- Minimal usage | ~$0.05/month |
| **Data Transfer** | - Outbound to internet<br>- Cross-AZ traffic | ~$5-20/month |
| **CloudWatch** | - Logs and metrics<br>- App Runner monitoring | ~$5-10/month |

### Total Estimated Monthly Cost
- **Minimum (low traffic)**: ~$105/month
- **Typical (moderate traffic)**: ~$150/month
- **Maximum (high traffic)**: ~$220/month

### Cost Optimization Tips
1. **Development Environment**: 
   - Reduce Aurora ACU minimum to 0.5
   - Use single App Runner instance
   - Schedule automatic shutdown during non-working hours
   - Estimated cost: ~$50-70/month

2. **Production Optimization**:
   - Use Aurora Serverless v2 auto-pause (if applicable)
   - Implement caching to reduce database queries
   - Use CloudFront for static assets
   - Monitor and adjust App Runner scaling policies

3. **Free Tier Benefits** (if eligible):
   - 750 hours of t2.micro EC2 (not used in this setup)
   - 5 GB of S3 storage
   - 1 million Lambda requests (if added)
   - 1 GB of data transfer

### Cost Monitoring
Set up AWS Budget alerts:
```bash
# Example: Create a $200/month budget alert
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

## Deploy-on-Change Workflow

### What is Deploy-on-Change?
The `deploy-on-change.yml` workflow is an intelligent deployment system that automatically detects which components have been modified and deploys only those specific parts. This provides several benefits:

### Benefits
1. **Faster Deployments**: Only rebuilds and deploys changed components
2. **Resource Efficiency**: Saves CI/CD minutes and AWS API calls
3. **Reduced Risk**: Minimizes the blast radius of deployments
4. **Cost Optimization**: Avoids unnecessary infrastructure reprovisioning
5. **Parallel Development**: Teams can work independently on different components

### How It Works
The workflow monitors changes in three directories:
- `infra/` - Infrastructure changes trigger Terraform updates
- `server/` - Backend changes trigger Docker build and App Runner update
- `web/` - Frontend changes trigger Next.js build (deployment target configurable)

### Example Scenarios

**Scenario 1: Backend Bug Fix**
- Developer fixes a bug in the .NET API
- Pushes to main branch
- Only the server job runs:
  - Builds new Docker image
  - Pushes to ECR
  - Updates App Runner service
- Infrastructure and frontend remain untouched
- Deployment time: ~3-5 minutes

**Scenario 2: Database Schema Update**
- Changes to `infra/2-resources/modules/aurora/`
- Only infrastructure job runs:
  - Updates Aurora configuration
  - No server rebuild needed
- Deployment time: ~5-10 minutes

**Scenario 3: Full Stack Feature**
- Changes across all three components
- All jobs run but in optimized order:
  - Infrastructure updates first
  - Server and web deploy in parallel
- Deployment time: ~10-15 minutes

### Enabling Deploy-on-Change
Add the workflow to your repository:
```bash
cp deploy-on-change.yml .github/workflows/
git add .github/workflows/deploy-on-change.yml
git commit -m "feat: add smart deployment workflow"
git push
```

### Customizing Component Detection
You can modify the path triggers in the workflow:
```yaml
on:
  push:
    paths:
      - 'infra/**'
      - 'server/**'
      - 'web/**'
      - 'shared/**'  # Add more paths as needed
```

## Step-by-Step Setup

### 1. Create GitHub Workflows Directory
```bash
# From your monorepo root
mkdir -p .github/workflows
```

### 2. Copy Workflow Files
Save the following files to `.github/workflows/`:
- `deploy-full-stack.yml` - Main deployment workflow
- `deploy-on-change.yml` - Component-specific deployment (optional but recommended)
- `destroy-full-stack.yml` - Infrastructure teardown workflow

### 3. Prepare Unified Secrets

#### 3.1 Create your secrets file
```bash
# Copy the template
cp .secrets.unified.example .secrets.unified

# Edit with your actual values
nano .secrets.unified  # or use your preferred editor
```

#### 3.2 Fill in all required values:
- **AWS Credentials**: Both admin and resources-creator IAM user credentials
- **Database Password**: Strong password for Aurora PostgreSQL
- **OpenAI API Key**: For AI features in your application
- **AWS Region**: Your preferred AWS region (e.g., us-east-1)
- **Terraform Variables**: Prefix for resource naming, profile names

#### 3.3 Encode secrets for GitHub
```bash
# Make the script executable
chmod +x prepare-secrets.sh

# Run the preparation script
./prepare-secrets.sh
```

This will:
- Validate all required secrets are present
- Create a base64 encoded version
- Save it to `.secrets.unified.b64`
- Provide instructions for GitHub setup

### 4. Add Secret to GitHub

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `UNIFIED_SECRETS_B64`
5. Value: Paste the entire content of `.secrets.unified.b64`
6. Click **Add secret**

### 5. Clean Up Local Secrets
```bash
# Remove the encoded file after adding to GitHub
rm .secrets.unified.b64

# Ensure secrets are in .gitignore
cat .gitignore | grep secrets
# Should show: .secrets*
```

### 6. Update Dockerfile Path
Ensure your server's Dockerfile path is correct. The workflow expects it at:
- `server/Dockerfile`

If it's in a different location (like `server/server.Infrastructure/Dockerfile`), update line 175 in `deploy-full-stack.yml`:
```yaml
docker build -t ${{ env.ECR_URL }}:latest -t ${{ env.ECR_URL }}:${{ env.SHORT_SHA }} -f server.Infrastructure/Dockerfile .
```

## Deployment Process

### Automatic Deployment (on push to main)
Every push to the `main` branch will trigger the appropriate deployment:
- **With deploy-full-stack.yml**: Always runs complete deployment
- **With deploy-on-change.yml**: Only deploys changed components

### Manual Deployment
You can also trigger deployment manually from GitHub Actions:
1. Go to **Actions** tab
2. Select **Deploy Full Stack**
3. Click **Run workflow**
4. Choose which components to deploy:
   - Deploy Infrastructure
   - Deploy Server
   - Deploy App Runner

### Viewing Deployment Status
1. Go to the **Actions** tab in your repository
2. Click on the running workflow
3. View real-time logs for each job
4. Check the summary for the App Runner URL

## Infrastructure Teardown

To destroy all AWS resources:
1. Go to **Actions** tab
2. Select **Destroy Full Stack**
3. Click **Run workflow**
4. Type `DESTROY` to confirm
5. The workflow will remove resources in reverse order:
   - App Runner → Resources → Admin

**Warning**: This will delete all data including databases. Ensure you have backups if needed.

## Security Best Practices

### Local Development
- Never commit `.secrets.unified` to Git
- Use `.secrets.unified.example` as documentation
- Keep secrets file permissions restricted: `chmod 600 .secrets.unified`

### GitHub Actions
- Secrets are masked in logs automatically
- Use GitHub's secret scanning to detect exposed credentials
- Regularly rotate AWS access keys
- Use least-privilege IAM policies

### AWS Security
- Database password is stored in Terraform state (encrypted in S3)
- App Runner uses IAM roles for ECR access
- VPC isolates database from public internet
- Security groups restrict access appropriately

## Environment Variables Mapping

The unified secrets file provides all necessary configuration:

| Secret Variable | Used By | Purpose |
|----------------|---------|---------|
| AWS_ADMIN_* | Terraform Admin | Create IAM resources |
| AWS_RESOURCES_CREATOR_* | Terraform Resources, Docker, App Runner | Deploy application resources |
| TF_VAR_DB_PASSWORD | Aurora Database, Application | Database authentication |
| OPENAI_API_KEY | Application | AI features |
| TF_VAR_PREFIX | All Terraform | Resource naming |

## Dynamic Configuration

The workflow automatically:
- Retrieves Aurora endpoint from Terraform outputs
- Gets ECR URL for Docker push
- Generates `appsettings.Production.json` with correct values
- Passes infrastructure outputs between jobs

## Troubleshooting

### Common Issues

#### 1. Terraform State Issues
```bash
# If you see state lock errors
cd infra/1-admin  # or relevant directory
terraform force-unlock <LOCK_ID>
```

#### 2. ECR Login Failed
- Verify AWS credentials have ECR permissions
- Check AWS region matches ECR repository region

#### 3. App Runner Not Starting
- Check CloudWatch logs in AWS Console
- Verify database connection string
- Ensure Docker image was pushed successfully

#### 4. Secrets Not Found
- Verify `UNIFIED_SECRETS_B64` exists in GitHub Secrets
- Check base64 encoding is correct
- Ensure no line breaks in encoded secret

#### 5. S3 State Bucket Not Found
- Ensure you created the bucket manually before running Terraform
- Verify bucket name matches: `{prefix}-terraform-state-unique1029`
- Check bucket is in the correct region (us-east-1)

### Debugging Steps
1. Check GitHub Actions logs for specific error
2. Verify AWS Console for resource creation
3. Use `terraform plan` locally to test configuration
4. Check AWS CloudWatch for application logs

## Next Steps

### Adding Frontend Deployment
To add web deployment to the workflow:
1. Add a new job in `deploy-full-stack.yml` after `deploy_app_runner`
2. Build Next.js application
3. Deploy to S3/CloudFront or Amplify
4. Update App Runner environment variables with frontend URL

### Adding Staging Environment
1. Create separate secrets: `UNIFIED_SECRETS_STAGING_B64`
2. Duplicate workflows with `-staging` suffix
3. Use different Terraform workspaces or prefixes
4. Deploy to different AWS accounts/regions

## Maintenance

### Regular Tasks
- Review and rotate AWS credentials quarterly
- Update Terraform providers periodically
- Monitor AWS costs through Cost Explorer
- Review CloudWatch logs for errors
- Update dependencies in Docker images

### Backup Strategy
- Terraform state is stored in S3 with versioning
- Database has automated backups enabled
- Keep local backup of `.secrets.unified` securely
- Document any manual AWS Console changes

## Support

For issues or questions:
1. Check workflow logs in GitHub Actions
2. Review AWS CloudWatch logs
3. Verify Terraform state consistency
4. Ensure all secrets are properly set
5. Verify S3 state bucket exists and is accessible