## Initial AWS Configuration

1. Navigate to the `1-admin` directory and review `main.tf` to understand the required AWS console configuration:
    1. Create the S3 bucket to manage Terraform state
    2. Create and attach to the AWS ADMIN profile the initial policy

2. Adjust the secrets for the folder .github/workflows:
    1. Create a `.secrets` file based on the provided example:
    ```bash
    cp .secrets.example .secrets
    ```
    2. Edit the `.secrets` file with your AWS credentials and configuration:

    * AWS ADMIN is the AWS profile that is going to give the AWS RESOURCE CREATOR profile permission to create all resources needed by this app
    * AWS RESOURCES CREATOR is the AWS profile that is going to create these resources

    3. Export the secrets to base64 and create and add them to a variable in GitHub secrets called `ENCODED_SECRETS`:
        ```bash
        base64 -i .secrets
        ```

## Infrastructure Deployment

The infrastructure deployment is split into two main steps:

### Step 1: Admin Infrastructure
Deploys the initial AWS resources and permissions needed for the application.

### Step 2: Application Resources
Deploys the application-specific resources:
- RDS (PostgreSQL database)
- ECR (Container registry for Docker images)
- S3 (File storage)
- SQS (Message queue)

### Step 3: App Runner
Before this step, the docker image file of the backend application needs to be deployed to the ECR of the previous step.
After the docker image is in ECR of aws, you can deploy App Runner manually triggering it (app-runner.yml).

### Deployment Methods

#### Using GitHub Actions (Recommended)
1. Push your changes to the repository
2. The `1-deploy.yml` workflow will automatically run the steps defined in the folders `1-admin` and `2-resources`

#### Local Development
You can also run the workflow locally. Run this command in the root of the infra folder:

macOs/linux:
```bash
act -s ENCODED_SECRETS="$(base64 -i .secrets | tr -d '\n')" --container-architecture linux/amd64
```

windows (powershell):
```bash
act -s ENCODED_SECRETS="$([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Raw .secrets))))" --container-architecture linux/amd64
```

### Deployment Outputs

After successful deployment, note down the following workflow outputs:
- *ECR Repository URL*: For storing Docker images
- *RDS Endpoint*: Database connection string
- *S3 Bucket Name*: For file storage
- *SQS Delete User URL*: For user deletion queue

## App Runner Deployment

After the infrastructure is deployed, you need to deploy the App Runner service:

1. Go to your GitHub repo → Click on "Actions"
2. On the left sidebar, locate "app-runner.yml"
3. Click "Run workflow" (usually a dropdown button) and confirm
4. After successful deployment, note down the App Runner service URL from the outputs

- *App Runner URL*: The production url of the application

## Destroying Resources

To destroy all infrastructure and server resources:

1. Execute the destroy workflow manually:
    - Go to your GitHub repo → Actions
    - Locate and run `workflows/destroy.yml`

2. Manually delete the following resources:
    - S3 bucket created in step 1.1.2
    - Initial policy created in step 1.1.2

## Project Structure

```
terraform/
├── 1-admin/           # Initial AWS resources and permissions
├── 2-resources/       # Application-specific resources
└── workflows/         # GitHub Actions workflows
    ├── 1-deploy.yml   # Main deployment workflow
    ├── app-runner.yml # App Runner deployment
    └── destroy.yml    # Resource cleanup
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License—see the LICENSE file for details. 