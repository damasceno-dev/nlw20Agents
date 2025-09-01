# 💰 AWS Cost Analysis and Recommendations

**Last reviewed:** 2025-09-01  
**Region assumed:** us-east-1 (pricing varies by region)

## 📊 Executive Summary

When the full-stack infrastructure is deployed, expect baseline monthly costs of **$95–$150+**, primarily driven by:
- **AWS App Runner** (1 vCPU, 2 GB) — always-on backend API hosting
- **Amazon Aurora Serverless v2** (min capacity 0.5 ACU) — managed PostgreSQL database  
- **AWS Amplify** — frontend hosting and CI/CD for Next.js application

With light usage, expect costs around **$100-120/month**. For production workloads, budget **$150-250/month**.

## 🏗️ AWS Services Deployed and Costs

### 1. **VPC and Networking** (infra/2-resources/modules/vpc)
- **Components:** 1 VPC, 2 public subnets, 1 Internet Gateway, 1 route table, 2 associations
- **Cost Impact:** **$0/month** for these components
- **Note:** No NAT Gateways deployed (good cost optimization; NATs would add ~$30–$35 each/month plus data processing)

### 2. **Amazon Aurora Serverless v2 PostgreSQL** (infra/2-resources/modules/aurora)
- **Configuration:** 
  - Serverless v2 scaling: min 0.5 ACU, max 2 ACU
  - 1 cluster with 1 instance (db.serverless), publicly accessible
- **Cost Drivers:**
  - **ACU-hours:** Charged per second, minimum 0.5 ACU when idle
  - **Storage:** GB-month for data storage
  - **I/O:** Per request charges
- **Monthly Estimate:**
  - **ACU:** ~0.5 ACU × $0.12/ACU-hr × 730 hrs = **~$44/month**
  - **Storage/I/O:** **$5–$15/month** for small applications
  - **Total Aurora: $45–$60/month**

### 3. **AWS App Runner** (infra/3-apprunner)
- **Configuration:** 1 vCPU, 2 GB RAM (.NET API hosting)
- **Behavior:** Always-on (does not scale to zero)
- **Cost Drivers:**
  - **Compute:** $0.064 per vCPU-hour
  - **Memory:** $0.007 per GB-hour
  - **Formula:** (0.064 × 1) + (0.007 × 2) = $0.078/hour
- **Monthly Estimate:** $0.078 × 730 hrs = **~$57/month**
- **With traffic:** **$55–$70/month**

### 4. **AWS Amplify** (Frontend Hosting)
- **Features:**
  - **Hosting:** Next.js static/SSR hosting with CDN
  - **CI/CD:** Automatic builds from GitHub
  - **Custom Domain:** SSL certificates included
- **Cost Drivers:**
  - **Build minutes:** $0.01 per build minute
  - **Hosting:** $0.15 per GB stored + $0.15 per GB served
  - **Requests:** $0.30 per million requests
- **Monthly Estimate:**
  - **Builds:** ~20 builds × 5 min = **$1/month**
  - **Hosting:** ~1 GB stored + 10 GB served = **$1.65/month**
  - **Requests:** Light traffic = **$1-3/month**
  - **Total Amplify: $3-6/month**

### 5. **Amazon ECR** (Container Registry)
- **Purpose:** Docker image storage for .NET API
- **Configuration:** Private repository with lifecycle (untagged images deleted after 7 days)
- **Monthly Estimate:** **$1–$5/month** for typical usage

### 6. **Supporting Services**
- **S3:** Terraform state storage = **$1-2/month**
- **CloudWatch Logs:** Application logging = **$2-5/month**
- **Data Transfer:** Varies by usage = **$2-10/month**

## 📊 Monthly Cost Summary

### Development Environment (Light Usage)
| Service                  | Cost Range    | Notes                              |
|--------------------------|---------------|------------------------------------|
| **Aurora Serverless v2** | $45–$60       | Minimum 0.5 ACU always running     |
| **App Runner**           | $55–$70       | 1 vCPU, 2GB RAM always-on          |
| **AWS Amplify**          | $3–$6         | Low build frequency, light traffic |
| **ECR**                  | $1–$5         | Docker image storage               |
| **Supporting Services**  | $5–$15        | S3, CloudWatch, data transfer      |
| **💰 Total Development** | **$109–$156** |                                    |

### Production Environment (Moderate Usage)
| Service                  | Cost Range    | Notes                          |
|--------------------------|---------------|--------------------------------|
| **Aurora Serverless v2** | $60–$120      | Higher ACU usage, more storage |
| **App Runner**           | $70–$150      | Higher traffic, data transfer  |
| **AWS Amplify**          | $10–$25       | More builds, higher traffic    |
| **ECR**                  | $5–$10        | Multiple image versions        |
| **Supporting Services**  | $15–$35       | More logs, data transfer       |
| **💰 Total Production**  | **$160–$340** |                                |

## ⚠️ Cost Optimization Strategies

### 🔥 Immediate Cost Savers

1. **Destroy When Not In Use**
   ```bash
   # GitHub Actions → "Destroy with OIDC" → type DESTROY
   # Saves ~$100+/month when resources are not needed
   ```

2. **Aurora Alternatives for Development**
   - **RDS t4g.micro:** ~$15-25/month (vs $45-60 for Aurora)
   - **PostgreSQL on Lightsail:** ~$10-20/month
   - **Local PostgreSQL:** $0 (development only)

3. **App Runner Optimization**
   - Current configuration is already at minimum (1 vCPU, 2GB)
   - Consider **AWS Lambda + API Gateway** for intermittent usage
   - Estimated Lambda cost: ~$5-15/month for light usage

### 📈 Production Optimizations

1. **CloudFront Integration**
   - Add CloudFront for Amplify hosting
   - Reduces Amplify data transfer costs
   - Better global performance

2. **Aurora Scaling Policies**
   - Fine-tune min/max ACU based on actual usage
   - Consider Aurora I/O Optimized for high-traffic apps

3. **Monitoring and Alerts**
   - Set AWS Budget alerts at $150, $200, $300 thresholds
   - Use CloudWatch to identify cost spikes

## 🚨 Cost Risk Factors

### High-Risk Items
- **Aurora baseline:** $45-60/month minimum (cannot scale to zero)
- **App Runner baseline:** $55-70/month minimum (always-on)
- **NAT Gateways:** Would add $30-35 each/month (currently not deployed ✅)

### Potential Surprise Costs
- **Data Transfer:** Can spike with high traffic or external API calls
- **Aurora I/O:** Heavy database operations increase costs
- **Amplify Builds:** Frequent deployments add build minute charges

## 🛠️ GitHub Workflows Impact on Costs

| Workflow                | Cost Impact                        | Recommendation                             |
|-------------------------|------------------------------------|--------------------------------------------|
| `deploy-with-oidc.yml`  | High - deploys full infrastructure | Use manually for production deployments    |
| `deploy-on-change.yml`  | Medium - auto-deploys on changes   | Consider manual approval for infra changes |
| `destroy-with-oidc.yml` | Negative - saves money             | Use regularly for dev/test environments    |

## 💡 Quick Cost Check Commands

**Verify All Resources Destroyed:**
```bash
# Check App Runner
aws apprunner list-services --region us-east-1

# Check Aurora
aws rds describe-db-clusters --region us-east-1

# Check ECR repositories
aws ecr describe-repositories --region us-east-1
```

**Destroy Everything:**
1. GitHub Actions → "Destroy with OIDC"
2. Type `DESTROY` to confirm
3. Wait ~10 minutes for completion
4. Verify in AWS Console that all resources are removed

## 📝 Important Notes

- **Prices are estimates** and vary by region/usage - use AWS Pricing Calculator for precision
- **Aurora Serverless v2** cannot scale to zero (minimum 0.5 ACU)
- **App Runner** always maintains at least one instance
- **Amplify** provides excellent value for frontend hosting with built-in CI/CD
- **All workflows are manual** - no accidental deployments unless explicitly triggered
