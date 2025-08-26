# Full-Stack Project Setup Guide with OIDC

## Overview
This is a complete full-stack application with modern, secure CI/CD using GitHub OIDC authentication. No AWS credentials are stored in GitHub - instead, we use temporary, auto-rotating credentials with 1-hour TTL.

## Architecture
```
nlw20Agents/
├── .github/
│   └── workflows/
│       ├── oidc-first-time-setup.yml   # One-time OIDC setup
│       ├── deploy-with-oidc.yml         # Main deployment workflow
│       ├── destroy-full-stack.yml      # Complete infrastructure teardown
│       ├── cleanup-oidc-role.yml       # Project-specific OIDC cleanup
│       └── deploy-on-change.yml         # Smart component deployment
├── infra/
│   ├── 1-oidc/                         # GitHub OIDC setup
│   ├── 2-resources/                    # VPC, Aurora, ECR
│   └── 3-apprunner/                    # App Runner service
├── server/                             # .NET 9 Backend API
├── web/                               # Next.js Frontend
├── .initial_secrets.example           # Temporary AWS credentials
├── .secrets.example                   # Project configuration
└── prepare_secrets.sh                 # Secrets validation script
```

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

**1.1 Create S3 Bucket for Terraform State**
```bash
# Login to AWS Console as root user (with MFA)
# Navigate to S3 → Create bucket
# Configuration:
#   - Name: {your-prefix}-terraform-state-unique1029
#   - Region: us-east-1
#   - Versioning: ENABLED
#   - Encryption: ENABLED (AES-256)
#   - Block all public access: YES
```

> ⚠️ **Critical**: This bucket must be created MANUALLY before running any Terraform. Replace `{your-prefix}` with your project prefix (e.g., "agents").

**1.2 Create Temporary Setup User**
```bash
# Still in AWS Console as root:
# IAM → Users → Create user
# User name: temp-setup-{prefix}-{YYYYMMDD}
# Example: temp-setup-agents-20250826
# Attach policy: AdministratorAccess (AWS managed policy)
# Security credentials → Create access key → CLI
# ⚠️ Save these credentials in .initial_secrets file - you'll delete this user in 30 minutes!
```

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

**2.3 Edit `.initial_secrets` (temporary - will be deleted)**
```bash
nano .initial_secrets
```
```env
# Add the temporary AWS credentials from Step 1.2:
TEMP_AWS_ACCESS_KEY_ID=AKIA...
TEMP_AWS_SECRET_ACCESS_KEY=...
```

**2.4 Edit `.secrets` (permanent project configuration)**
```bash
nano .secrets
```
```env
# GitHub Configuration
GITHUB_ORG=your-github-username
GITHUB_REPO=nlw20Agents

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
OPENAI_API_KEY=your-open-api-key

```

**2.5 Prepare GitHub Secrets**
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

### Step 4: OIDC Setup (One-Time per AWS account; per-repo role auto-created)

## Project Isolation Strategy

This setup is designed for **per-project isolation** with shared OIDC infrastructure:

### 🔐 Per-Project Resources (Created Every Time):
- ✅ **Separate S3 bucket per project** (`{prefix}-terraform-state-unique1029`)
- ✅ **Separate GitHub Deploy Role** (`{prefix}-github-deploy-role`)
- ✅ **Separate temporary AWS credentials** (deleted after setup)
- ✅ **Independent Terraform state** per project

### 🌐 Shared AWS Account Resources (One-Time):
- ✅ **GitHub OIDC Provider** (created once, automatically detected and reused)

### 🔍 Smart OIDC Detection:
- **First Project**: Creates OIDC provider + project role
- **Subsequent Projects**: Detects existing OIDC provider, skips creation, creates only project role
- **Clear Logging**: Shows exactly what's being created vs reused

### 🚀 Using This as a Template:

**For Each New Project:**
1. **Clone/Fork this repository**
2. **Create project-specific AWS resources:**
   - Create S3 bucket: `{new-prefix}-terraform-state-unique1029`
   - Create temporary AWS user: `temp-setup-{new-prefix}-{YYYYMMDD}`
3. **Update configuration files:**
   - Update `.initial_secrets` with new temporary AWS user credentials
   - Update `.secrets` file with new prefix (e.g., `TF_VAR_PREFIX=myapp`)
4. **Prepare and add GitHub secrets:**
   - Run `./prepare_secrets.sh` to encode files
   - Add `INITIAL_SECRETS_B64` and `SECRETS_B64` to GitHub repository secrets
5. **Run OIDC setup workflow** - it will detect existing OIDC and create only project resources

### ♻️ Cleanup Per Project:
Each project can be completely destroyed independently without affecting others.

**To cleanup OIDC role for this project:**
1. Go to **Actions** → **"Cleanup OIDC Role"**
2. Type `DESTROY-ROLE` to confirm
3. Choose whether to keep the shared OIDC provider (recommended if other projects use it)
4. Manually delete the S3 bucket: `{prefix}-terraform-state-unique1029`

**4.1 Run OIDC Setup Workflow**
1. Go to **Actions** tab in your GitHub repository
2. Select **"OIDC First Time Setup"** workflow
3. Click **"Run workflow"**
4. Type `SETUP` to confirm
5. Wait for completion (~5 minutes)

**4.2 Verify OIDC Setup**
The workflow will (create if missing, or verify if existing):
- GitHub OIDC provider in AWS (one-time per account)
- GitHub deployment role for this repository (per repo)
- Test OIDC authentication
- Output the role ARN for verification

### Step 5: Security Cleanup (Critical!)

**⚠️ IMMEDIATELY after OIDC setup succeeds:**

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

## 💰 Costs and Budget

For an estimate of monthly AWS costs for this setup and ways to keep costs below ~$100/month, see COSTS.md. In short: with App Runner (1 vCPU/2GB) and Aurora Serverless v2 (min 0.5 ACU) running, expect around $100+/month baseline. Use the "Destroy with OIDC" workflow to tear down when not in use.

## 🏗️ Deployment Workflows

After OIDC setup, you have three deployment options:

### Option 1: Full Deployment (Manual)
```bash
# GitHub Actions → "Deploy with OIDC" → Run workflow
# Choose which components to deploy:
# ✅ Deploy Infrastructure
# ✅ Deploy Server  
# ✅ Deploy App Runner
```

### Option 2: Smart Deployment (Automatic)
The `deploy-on-change.yml` workflow automatically detects which components changed and deploys only those:

- **Infrastructure changes** (`infra/**`) → Triggers full infrastructure deployment
- **Server changes** (`server/**`) → Builds and pushes new Docker image, restarts App Runner
- **Web changes** (`web/**`) → Builds frontend (deployment target configurable)

### Option 3: Component-Specific Deployment
Use workflow dispatch with specific components selected for targeted deployments.

## 🗑️ Infrastructure Teardown

To destroy all AWS resources:

1. **GitHub Actions** → **"Destroy Full Stack"**
2. Type `DESTROY` to confirm
3. Wait for completion (~10 minutes)

Destroys in proper order: App Runner → Resources → Admin → OIDC

## 📊 Infrastructure & Costs

### AWS Services Deployed

| Service                  | Configuration                  | Purpose                        |
|--------------------------|--------------------------------|--------------------------------|
| **GitHub OIDC Provider** | Trust relationship with GitHub | Secure authentication          |
| **Aurora Serverless v2** | 0.5-1 ACU, PostgreSQL          | Application database           |
| **App Runner**           | 0.25 vCPU, 0.5 GB RAM          | .NET API hosting               |
| **ECR**                  | Private repository             | Docker image storage           |
| **VPC**                  | 2 public + 2 private subnets   | Network isolation              |
| **NAT Gateway**          | Single AZ                      | Private subnet internet access |

### Monthly Cost Estimates (US East 1)

| Usage Level            | Estimated Cost  | Notes                            |
|------------------------|-----------------|----------------------------------|
| **Development**        | ~$50-70/month   | Single instance, minimal traffic |
| **Production (Light)** | ~$105/month     | Standard configuration           |
| **Production (Heavy)** | ~$150-220/month | High traffic, multiple instances |

### Cost Optimization Tips

1. **Dev Environment**: Use single App Runner instance, pause Aurora during off-hours
2. **Production**: Implement CloudFront, optimize Aurora scaling policies
3. **Monitoring**: Set up AWS Budget alerts for $200/month threshold

## 🔧 Development Workflow

### Local Development Setup

**Backend (.NET 9)**
```bash
cd server
dotnet restore
dotnet run --project server.API
# API available at: http://localhost:5000
```

**Frontend (Next.js)**
```bash
cd web
npm install
npm run dev
# Web app available at: http://localhost:3000
```

**Database (Local)**
```bash
# Option 1: Use Docker
docker run --name postgres-local -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:15

# Option 2: Connect to deployed Aurora (use connection string from AWS Console)
```

### Environment Variables

**Development (.NET)**
```json
// server/server.API/appsettings.Development.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=agents_dev;Username=postgres;Password=postgres"
  },
  "OpenAI": {
    "ApiKey": "sk-your-dev-key"
  }
}
```

**Production (Generated by CI/CD)**
The workflows automatically generate `appsettings.Production.json` with:
- Aurora endpoint from Terraform outputs
- Database credentials from secrets
- AWS configuration for OIDC authentication

## 🛠️ Troubleshooting

### Common Issues

**1. OIDC Setup Fails**
```bash
# Check if S3 bucket exists and is accessible
# Verify temporary AWS credentials have AdministratorAccess
# Ensure AWS account ID is correct in .secrets
```

**2. Deployment Fails - "Role cannot be assumed"**
```bash
# OIDC role doesn't exist or trust relationship is wrong
# Re-run "OIDC First Time Setup" workflow
# Check GitHub repository settings match .secrets configuration
```

**3. Database Connection Issues**
```bash
# Verify Aurora is in "available" state in AWS Console
# Check security group allows App Runner connections
# Confirm database password matches what's in .secrets
```

**4. App Runner Service Won't Start**
```bash
# Check CloudWatch logs: AWS Console → App Runner → Service → Logs
# Verify ECR image was pushed successfully
# Confirm appsettings.Production.json is valid JSON
```

**5. ECR Push Permission Denied**
```bash
# OIDC role might not have ECR permissions
# Check IAM policies in infra/1-oidc/modules/iam-policies/
```

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

- **Quarterly**: Review and rotate any remaining AWS credentials
- **Monthly**: Check AWS costs and optimize resources
- **Weekly**: Review CloudWatch logs for errors
- **As needed**: Update Terraform providers and GitHub Actions

### Backup Strategy

- **Terraform State**: Automatically versioned in S3
- **Database**: Aurora automatic backups (7-day retention)
- **Code**: Git repository with branch protection
- **Secrets**: Keep local backup of `.secrets` file securely

### Updates and Upgrades

**Update Dependencies**
```bash
# .NET packages
cd server && dotnet list package --outdated

# Node.js packages  
cd web && npm audit

# Terraform providers
cd infra && terraform init -upgrade
```

**Infrastructure Updates**
```bash
# Apply infrastructure changes:
# 1. Make changes to Terraform files
# 2. Push to main branch  
# 3. Deploy-on-change workflow triggers automatically
# OR manually trigger "Deploy with OIDC" workflow
```

## 📚 Additional Resources

### Documentation Links

- [GitHub OIDC with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS App Runner](https://docs.aws.amazon.com/apprunner/)
- [Aurora Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Project Structure Details

```
infra/
├── 1-oidc/              # GitHub OIDC trust setup
│   ├── main.tf          # OIDC provider and IAM role
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # GitHub role ARN
│   └── modules/
│       └── iam-policies/  # Least-privilege policies
├── 2-resources/         # Core infrastructure
│   ├── main.tf          # VPC, Aurora, ECR
│   └── modules/
│       ├── aurora/      # Database configuration
│       ├── vpc/         # Network setup
│       └── ecr/         # Container registry
└── 3-apprunner/         # Application hosting
    └── main.tf          # App Runner service
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes and test locally
4. Ensure all workflows pass in your fork
5. Create pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🆘 Support

For issues or questions:

1. **Check workflow logs** in GitHub Actions
2. **Review AWS CloudWatch** logs for runtime issues  
3. **Verify Terraform state** consistency
4. **Ensure all secrets** are properly configured
5. **Confirm S3 state bucket** exists and is accessible

**Need help?** Open an issue in this repository with:
- Steps to reproduce the problem
- Relevant log output (redact sensitive information)
- Your environment details (AWS region, project prefix, etc.)