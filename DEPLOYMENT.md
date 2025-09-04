# 🚀 Deployment Guide

## 🔐 Security Model: OIDC Authentication

This project uses **GitHub OIDC** instead of storing AWS credentials:

- ✅ **Zero AWS credentials in GitHub**
- ✅ **Temporary credentials** (1-hour TTL)
- ✅ **Automatic credential rotation**
- ✅ **Complete audit trail** in CloudWatch
- ✅ **SOC2/ISO 27001 compliance ready**

## 🚀 Quick Start (First Time Setup)

Follow these steps to set up your full-stack project with secure OIDC authentication:

### Step 1: AWS Account Prerequisites

**Create Temporary Setup User**
```bash
# Login to AWS Console with admin access
# IAM → Users → Create user
# User name: temp-setup-{prefix}-{YYYYMMDD}
# Example: temp-setup-agents-20250904
# Attach policy: AdministratorAccess (AWS managed policy)
# Security credentials tab → Create access key → CLI
# ⚠️ Save these credentials - you'll need them in Step 2
```

> 📝 **Note**: The OIDC workflow will create the S3 bucket for Terraform state automatically - no manual S3 setup needed!

### Step 2: Local Configuration

**2.1 Clone and Configure**
```bash
git clone https://github.com/your-org/nlw20Agents.git
cd nlw20Agents
```

**2.2 Create Secret Files**
```bash
# Copy templates
cp .initial_secrets.example .initial_secrets
cp .secrets.example .secrets
```

**Edit `.initial_secrets` (temporary - will be deleted)**
```bash
nano .initial_secrets
```
```env
# Add the temporary AWS credentials from Step 1:
TEMP_AWS_ACCESS_KEY_ID=AKIA...
TEMP_AWS_SECRET_ACCESS_KEY=...
```

**Edit `.secrets` (permanent project configuration)**
```bash
nano .secrets
```
```env
# GitHub Configuration
GITHUB_ORG=your-github-username
GITHUB_REPO=nlw20Agents
GH_PAT=your-github-personal-access-token

# AWS Configuration  
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012

# Project Configuration
TF_VAR_PREFIX=agents

# Database Configuration
TF_VAR_DB_PASSWORD=your-secure-password-here
DB_NAME=agents
DB_USERNAME=postgres

# Application Configuration
OPENAI_API_KEY=your-openai-api-key
```

**📝 Note on GitHub Personal Access Token (GH_PAT):**
The `GH_PAT` is required for AWS Amplify to access your GitHub repository and create webhooks for automatic deployments.

To create a GitHub Personal Access Token:
1. Your profile picture → Settings → Developer settings (down under) → Fine-grained tokens
2. Click "Generate new token"
3. Give it a name like "Amplify Deployment"
4. Only select repositories → Select your repo
5. Give it full write permission on the repo
6. Copy the generated token and use it as the `GH_PAT` value in your `.secrets` file

**2.3 Prepare GitHub Secrets**
```bash
# Validate and encode secrets
chmod +x prepare_secrets.sh
./prepare_secrets.sh
```

This creates two base64-encoded files:
- `.initial_secrets.b64` → GitHub Secret: `INITIAL_SECRETS_B64`
- `.secrets.b64` → GitHub Secret: `SECRETS_B64`

### Step 3: GitHub Repository Setup

**3.1 Push Code to GitHub**
```bash
git add .
git commit -m "feat: add OIDC workflows and initial configuration"
git push origin main
```

**3.2 Add Secrets to GitHub**
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Create two repository secrets:

   **Secret 1: INITIAL_SECRETS_B64**
   - Name: `INITIAL_SECRETS_B64`
   - Value: Paste entire content of `.initial_secrets.b64`
   
   **Secret 2: SECRETS_B64**
   - Name: `SECRETS_B64`  
   - Value: Paste entire content of `.secrets.b64`

### Step 4: OIDC Setup (One-Time Setup with Automatic S3 Creation)

**4.1 Run OIDC First-Time Setup**
1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Find **"OIDC First Time Setup"** workflow
4. Click **"Run workflow"**
5. Type `SETUP` in the confirmation field
6. Click **"Run workflow"** (green button)
7. Wait for completion (~5-10 minutes)

This workflow will automatically:
- 🪣 **Create S3 bucket** for Terraform state if not exists (with versioning, encryption, and lifecycle rules)
- ✅ Create or detect existing GitHub OIDC Provider in your AWS account
- ✅ Create a project-specific OIDC role with least-privilege policies
- ✅ Set up secure GitHub → AWS authentication
- ✅ **Create tf-cleanup-role** for cleaning up the s3 state bucket (if not exists)
  - solving a chicken-and-egg problem with IAM role: OIDC role needs terraform state bucket to get properly deleted, and S3 needs an OIDC role to get deleted as well. 
  - This cleanup role is shared across projects, and it serves only to delete the S3 bucket that has the terraform state for this project.
  - This role is created automatically if it doesn't exist.

**What Gets Created:**
- **S3 Bucket**: `{prefix}-terraform-state-unique1029` (automatic!)
  - Versioning: Enabled
  - Encryption: AES-256
  - Public Access: Blocked
  - Lifecycle: Old versions deleted after 90 days
- **OIDC Provider**: Shared across AWS account (reused if exists)
- **IAM Role**: `{prefix}-github-deploy-role` (project-specific)
- **IAM Policies**: Least-privilege access for deployments
- **IAM Role**: `tf-clean-up-role` reused if exists
- **IAM Policies**: Least-privilege access for cleanup S3 terraform state bucket

### Step 5: Test Full Deployment (Before Cleanup!)

**🚀 CRITICAL: Test your deployment BEFORE deleting temporary credentials:**

1. **Run the "Deploy with OIDC" workflow** to verify OIDC works end-to-end
2. **Confirm all resources deploy successfully** (infrastructure, server, app runner)
3. **Only proceed to clean up after successful deployment**

> **Why?** If OIDC has permission issues or other problems, you will need the temporary credentials to fix them. Don't delete your safety net until you know everything works!

### Step 6: Final Step - Security Cleanup (ONLY AFTER SUCCESSFUL DEPLOYMENT)

**⚠️ Keep temporary credentials until deployment succeeds:**

1. **Delete temporary AWS user:**
   ```bash
   # In AWS Console: IAM → Users → temp-setup-{prefix}-{date} → Delete
   ```

2. **Delete temporary GitHub secret:**
   ```bash
   # GitHub repo → Settings → Secrets → INITIAL_SECRETS_B64 → Delete
   ```

3. **Clean up local files:**
   ```bash
   rm .initial_secrets
   rm .initial_secrets.b64 .secrets.b64
   ```

4. **Keep only SECRETS_B64** in GitHub for all future deployments

## 🎯 Simplified Setup Summary

The setup has been streamlined from multiple manual steps to just one:

| Step | Action               | Manual/Auto                  | Time      |
|------|----------------------|------------------------------|-----------|
| 1    | Create temp IAM user | Manual (or via bootstrap.sh) | 2 min     |
| 2    | Configure secrets    | Script assisted              | 3 min     |
| 3    | Add to GitHub        | Manual (or via gh CLI)       | 2 min     |
| 4    | Run OIDC workflow    | Auto (creates S3 + OIDC)     | 5-10 min  |
| 5    | Test deployment      | Auto                         | 15-25 min |

**Total: ~30–45 minutes from zero to deployed application!**

## 🗂️ Project Isolation Strategy

This setup is designed for **per-project isolation** with shared OIDC infrastructure:

### 📁 Per-Project Resources (Created Automatically):
- ✅ **S3 bucket** (`{prefix}-terraform-state-unique1029`) - Created by OIDC workflow
- ✅ **GitHub Deploy Role** (`{prefix}-github-deploy-role`)
- ✅ **Terraform state** (stored in project's S3 bucket)
- ✅ **All application resources** (RDS, App Runner, Amplify, etc.)

### 🌐 Shared AWS Account Resources (One-Time):
- ✅ **GitHub OIDC Provider** (created once, automatically detected and reused)

### 🔍 Smart OIDC Detection:
- **First Project**: Creates OIDC provider + S3 bucket + project role
- **Subsequent Projects**: Detects existing OIDC provider, creates new S3 bucket + project role
- **Clear Logging**: Shows exactly what's being created vs reused

### 🚀 Using This as a Template:

**For Each New Project:**
1. **Clone/Fork this repository**
2. **Create temporary AWS user**: `temp-setup-{new-prefix}-{YYYYMMDD}`
3. **Update configuration**:
   - Set new `TF_VAR_PREFIX` in `.secrets`
   - Update GitHub repo details
4. **Run setup**:
   - `./prepare_secrets.sh`
   - Add secrets to GitHub
   - Run OIDC workflow (S3 bucket created automatically!)
5. **Deploy and cleanup**

## 💰 Costs and Budget

For comprehensive cost analysis, service-by-service breakdowns, optimization strategies, and hibernation savings calculator, see **[COSTS.md](COSTS.md)**.

**Quick Summary:** 
- **Active deployment**: $109-340/month
- **During hibernation**: **$0/month** (true zero cost!)

## 🗄️ Deployment Workflows

### 📋 Available Workflows

| Workflow                    | Purpose                | Prerequisites       | Duration   |
|-----------------------------|------------------------|---------------------|------------|
| `oidc-first-time-setup.yml` | Setup OIDC + Create S3 | Temp IAM user       | ~5-10 min  |
| `deploy-with-oidc.yml`      | Full deployment        | OIDC setup complete | ~15-25 min |
| `hibernate-project.yml`     | Zero-cost hibernation  | Resources deployed  | ~10-15 min |

### 🔐 OIDC First-Time Setup
**Purpose:** Establish secure GitHub OIDC authentication and create infrastructure foundation

**What it creates automatically:**
- 🪣 S3 bucket for Terraform state (with all security settings)
- 🔐 GitHub OIDC provider (if not exists)
- 👤 Project-specific IAM role
- 📜 Least-privilege IAM policies

**When to run:** Once per project, before any deployments

### 🚀 Main Deployment (Deploy with OIDC)
**Purpose:** Deploy complete application infrastructure to AWS

**What it deploys:**
- **Backend:** .NET API on AWS App Runner
- **Frontend:** Next.js app on AWS Amplify
- **Database:** Aurora PostgresSQL with pgvector
- **Network:** VPC with public/private subnets
- **Registry:** ECR for Docker images

**Workflow Stages:**
1. Infrastructure (VPC, RDS, ECR)
2. Server build and ECR push
3. App Runner deployment
4. Amplify deployment
5. CORS configuration

### 🛌 Project Hibernation
**Purpose:** Achieve zero-cost hibernation while preserving code and configurations

**What it destroys (in order):**
1. App Runner service (compute costs)
2. Amplify app (hosting costs)
3. RDS/VPC/ECR (storage/network costs)
4. Project OIDC role
5. S3 state bucket (final cleanup)

**What it preserves:**
- 🔐 Shared OIDC provider (for other projects)
- 📝 All code and configurations
- 🔧 GitHub repository and workflows

**Reactivation process:**
1. Create new temp IAM user
2. Run `oidc-first-time-setup.yml` (recreates S3 for terraform state management, OIDC roles and tf-cleanup-role)
3. Run `deploy-with-oidc.yml` (redeploys everything)

## 🛠️ Troubleshooting

### Common Issues

**1. OIDC Setup Fails**
```bash
# Check if S3 bucket exists and is accessible
# Verify temporary AWS credentials have AdministratorAccess
# Ensure AWS account ID is correct in .secrets
```

**2. S3 Bucket Creation Fails**
```bash
# The OIDC workflow now creates S3 automatically
# If it fails, check:
# - AWS region is valid
# - Bucket name is unique (includes unique1029 suffix)
# - Temp credentials have S3 permissions
```

**3. Deployment Fails - "Role cannot be assumed"**
```bash
# OIDC role doesn't exist or trust relationship is wrong
# Re-run "OIDC First Time Setup" workflow with force recreation:
# - Check "Force recreation" option
# - Type SETUP and run
```

**4. Database Connection Issues**
```bash
# Verify Aurora is in "available" state
# Check App Runner → Configuration → Environment variables
# Ensure DB password in .secrets matches Aurora
```

**5. ECR Push Permission Denied**
```bash
# OIDC role might not have ECR permissions
# Check IAM policies in infra/1-oidc/modules/iam-policies/
```

**6. Amplify Deployment Fails (Next.js 15 SSR Complex Setup)**
```bash
# Check Amplify build logs in AWS Console
# Common Next.js 15 SSR issues with Amplify:

# Issue 1: Missing deploy-manifest.json
# Solution: Ensure web/scripts/prepare-amplify-deployment.js runs
# This creates .amplify-hosting/deploy-manifest.json with:
# - computeResources pointing to nodejs20.x runtime
# - entrypoint set to server.js
# - routes configured for SSR

# Issue 2: Standalone build not found
# Solution: Verify next.config.js has:
# output: "standalone"

# Issue 3: Static files not in correct location
# Solution: The script copies .next/static to the standalone build

# Issue 4: Server.js missing or in wrong location
# Solution: Script ensures server.js is at compute/default root

# Key Files Created by prepare-amplify-deployment.js:
# .amplify-hosting/
#   ├── deploy-manifest.json (SSR configuration)
#   └── compute/default/
#       ├── server.js (Next.js standalone server)
#       ├── .next/static/ (static assets)
#       └── public/ (public files)
```

**Amplify SSR Deployment Process:**
1. `npm run build:amplify` (not regular build)
2. Creates standalone Next.js server
3. Generates deploy-manifest.json with compute resources
4. Copies files to .amplify-hosting structure
5. Amplify deploys using nodejs20.x runtime for SSR

The web/scripts/prepare-amplify-deployment.js handles the complexity to deploy Next.js 15 SSR correctly:
- Create deploy-manifest.json with the correct SSR configuration
- Copies standalone build to .amplify-hosting/compute/default/
- Ensures static files and public directory are in the right place
- Moves server.js to the correct location

**Different Build Command**

- Must use npm run build:amplify (not regular npm run build)
- This runs both next build AND the preparation script



### Debug Commands

**Check OIDC Role**
```bash
# In GitHub Actions workflow:
aws sts get-caller-identity
aws iam get-role --role-name agents-github-deploy-role
```

**Verify Infrastructure**
```bash
# Local Terraform inspection:
cd infra/2-resources
terraform init
terraform show
```

**App Runner Logs**
```bash
# View real-time logs:
aws logs tail /aws/apprunner/agents-app-runner-service --follow
```

## 🔄 Maintenance

### Regular Tasks

- **Monthly**: Review AWS costs in Cost Explorer
- **Quarterly**: Rotate GitHub PAT
- **As needed**: Update dependencies and packages

### Backup Strategy

- **Terraform State**: Automatically versioned in S3
- **Database**: Aurora automatic backups (7-day retention)
- **Code**: Git repository with branch protection
- **Secrets**: Keep local backup of `.secrets` file securely

### Updates and Upgrades

**Update Dependencies**
```bash
# .NET packages
cd server && dotnet outdated

# Node.js packages  
cd web && npm audit fix

# Terraform providers
cd infra && terraform init -upgrade
```

## 📚 Additional Resources

### Documentation Links

- [GitHub OIDC with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS App Runner](https://docs.aws.amazon.com/apprunner/)
- [Aurora Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Project Structure

```
nlw20Agents/
├── .github/workflows/        # GitHub Actions workflows
│   ├── oidc-first-time-setup.yml
│   ├── deploy-with-oidc.yml
│   └── hibernate-project.yml
├── infra/                   # Terraform infrastructure
│   ├── 1-oidc/             # OIDC setup
│   ├── 2-resources/        # Core AWS resources
│   ├── 3-apprunner/        # API deployment
│   └── 4-amplify/          # Frontend deployment
├── server/                  # .NET API
│   ├── Dockerfile
│   └── server.sln
├── web/                     # Next.js frontend
│   ├── package.json
│   └── next.config.ts
└── prepare_secrets.sh  # Secret encoding
```

## 🆘 Support

For issues or questions:

1. **Check GitHub Actions logs** for detailed error messages
2. **Review AWS CloudWatch** for runtime logs
3. **Verify all secrets** are properly configured
4. **Ensure S3 state bucket** was created successfully
5. **Check IAM permissions** for the OIDC role

**Need help?** Open an issue with:
- Workflow logs (redact sensitive data)
- Error messages
- Your configuration (prefix, region, etc.)
- Steps to reproduce the issue