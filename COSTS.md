# AWS Cost Analysis and Recommendations

Last reviewed: 2025-08-25
Region assumed: us-east-1 (pricing varies by region)

Summary
- When the infrastructure in this repo is fully deployed, the baseline monthly spend is likely around $95–$130+ per month, primarily due to:
  - AWS App Runner (1 vCPU, 2 GB) — always-on instance
  - Amazon Aurora Serverless v2 (min capacity 0.5 ACU)
- With light usage and minimal storage, you should expect the spend to hover at or slightly above $100/month unless resources are destroyed when not in use.

What gets deployed and potential monthly cost
1) VPC (infra/2-resources/modules/vpc)
- 1 VPC, 2 public subnets, 1 Internet Gateway, 1 route table, 2 associations
- Cost impact: Typically $0 for these components (no NAT Gateways here — good; NATs can be ~$30–$35/each/month plus data).

2) Aurora PostgreSQL Serverless v2 (infra/2-resources/modules/aurora)
- Serverless v2 with serverlessv2_scaling_configuration: min_capacity = 0.5, max_capacity = 2
- Cluster and 1 instance (db.serverless), publicly accessible
- Cost drivers:
  - ACU-hours charged per second. With min 0.5 ACU, expect ~0.5 ACU billed when idle.
  - Storage (GB-month) and I/O requests billed separately.
- Ballpark estimate:
  - ACU: ~0.5 ACU × ~$0.12/ACU-hr × ~730 hr ≈ $43.8/month
  - Storage/I/O: $5–$15/month for small dev footprints
  - Total Aurora: roughly $45–$60/month at low traffic

3) ECR (infra/2-resources/modules/ecr)
- ECR repository with lifecycle for untagged images after 7 days
- Cost drivers: image storage (GB-month), data transfer egress (if any)
- Ballpark: typically $1–$5/month for small repos

4) App Runner (infra/3-apprunner)
- Instance configuration: cpu = 1024 (1 vCPU), memory = 2048 (2 GB)
- App Runner does not scale to zero; at least one instance remains active.
- Cost drivers:
  - Compute: ~$0.064 per vCPU-hour; Memory: ~$0.0075 per GB-hour
  - For 1 vCPU + 2 GB: (0.064 × 1) + (0.0075 × 2) = ~$0.079/hr
  - Monthly: ~$0.079 × ~730 hr ≈ ~$57.7/month (plus requests/data transfer)
- Ballpark: ~$55–$70/month with light traffic

5) Terraform state (S3 backend) and CloudWatch logs
- Typically a few cents to a couple of dollars per month depending on usage/log volume.

Workflows that can incur cost
- .github/workflows/deploy-with-oidc.yml: Can deploy infra, server (to ECR), and App Runner.
- .github/workflows/deploy-on-change.yml: Auto-triggers deployments based on changes. If infra files change, it can redeploy infrastructure and App Runner.
- .github/workflows/destroy-with-oidc.yml: Manual teardown to stop charges.

Key risks for exceeding $100/month
- App Runner baseline (~$58/mo) + Aurora Serverless v2 baseline (~$45–$60/mo) exceeds ~$100/mo combined, even with minimal usage.
- Adding NAT Gateways (currently not present) would add ~$30–$35 each per month plus data processing — avoid unless required.

Recommendations to keep costs down
- For dev/testing:
  1. Avoid leaving App Runner and Aurora running when not needed. Use the “Destroy with OIDC” workflow to tear down resources after testing.
  2. Consider replacing Aurora with:
     - RDS t4g/t3.micro or t4g/t3.small for dev (can be ~$10–$30/mo + storage), or
     - A lighter-weight DB (e.g., PostgreSQL on Lightsail) for experiments, or
     - In-memory/SQLite for local-only development.
  3. If you must keep App Runner:
     - Keep current size (1 vCPU, 2 GB) but be aware of the ~$58/mo baseline.
     - Reduce egress and external calls to control variable costs.
  4. Limit auto-deploy behavior:
     - Use deploy-with-oidc.yml manually when needed, rather than enabling deploy-on-change for infra.
     - Or modify deploy-on-change.yml so infra/app runner deployment is opt-in (manual approve step) to prevent accidental long-running environments.
  5. Security and potential hidden costs:
     - Aurora SG currently allows 0.0.0.0/0 on port 5432. Restrict to known CIDR/IPs to reduce risk of abuse/bad traffic (also helps avoid unwanted data transfer).

Estimated total monthly (light usage)
- Aurora Serverless v2: ~$45–$60
- App Runner: ~$55–$70
- ECR/S3/Logs/Data transfer: ~$2–$10
- Total: ~$102–$140

How to quickly avoid charges
- If you’ve deployed, run: GitHub Actions → “Destroy with OIDC” → type DESTROY
- Verify in AWS Console that all resources (App Runner, Aurora, ECR) are removed.

Notes
- Prices are approximate and change over time/region. Use the AWS Pricing Calculator with your exact region and expected usage for a precise estimate.
- App Runner minimum size in this config is already at the service’s lower bound (1 vCPU, 2 GB). Aurora Serverless v2 minimum is 0.5 ACU; it cannot scale to zero.
