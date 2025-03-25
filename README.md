# AWS S3 STATIC WEBSITE HOSTING WITH TERRAFORM AND JENKINS

## Overview
This project demonstrates how to deploy a static website using AWS S3, Terraform for infrastructure as code, and Jenkins for CI/CD automation. The infrastructure includes an S3 bucket for hosting, and Terraform state management using a remote S3 bucket with DynamoDB for state locking.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Terraform Setup](#terraform-setup)
- [Jenkins Automation](#jenkins-automation)
- [Deployment Workflow](#deployment-workflow)
- [Expected Output](#expected-output)
- [Conclusion](#conclusion)

## Prerequisites
- AWS account with IAM credentials.
- Terraform installed.
- Jenkins configured with a Multibranch Pipeline.
- An S3 bucket for storing Terraform state.
- A DynamoDB table for state locking.
- GitHub repository for source code management.

## Project Structure
```
mys3staticwebsite/
│-- main.tf
│-- variables.tf
│-- provider.tf
│-- outputs.tf
│-- index.html
│-- error.html
│-- profile.png
│-- backend.tf
│-- Jenkinsfile
```

## Terraform Setup
1. Define the AWS provider and required variables in `provider.tf` and `variables.tf`.
2. Create an S3 bucket for static website hosting in `main.tf`.
3. Configures public read access and bucket policies.
4. Upload `index.html` and `error.html` to the S3 bucket.
5. Store the Terraform state file in an S3 backend.
6. A DynamoDB table for state locking.

## Jenkins Automation
1. Add the repository to Jenkins.
2. Set up a multibranch pipeline.
3. Use the provided `Jenkinsfile` for automation.

## Deployment Workflow
1. **Push Changes:**
   - Developers work on the feature branch and push changes.
   - Jenkins runs Terraform `init` and `plan` but does not apply.
2. **Create Pull Request:**
   - A PR is created to merge changes into the main branch.
   - Review and approval are required before merging.
3. **Merge and Deploy:**
   - On merge, Jenkins detects the change and applies Terraform configurations.
   - S3 bucket is provisioned, and static website hosting is enabled.
   - A Slack notification is sent upon success or failure.

## Expected Output
### Terraform Output:
- S3 bucket is successfully created.
- Website files (`index.html`, `error.html`) are uploaded.
- Public access is enabled, allowing users to view the site.
- Terraform state file is stored in the configured S3 backend.

### Jenkins Pipeline Output:
- The pipeline successfully initializes, validates, and applies the Terraform configuration.
- Website files are deployed to S3.
- Terraform state file upload confirmation in the logs.
- Confirmation message showing a successful deployment.

### Website Access:
- Open the provided S3 static website URL in a browser.
- The homepage (`index.html`) should be displayed.
- Navigating to a non-existent page should show the custom `error.html` page.

## Conclusion
This project successfully automates S3 static website deployment using Terraform and Jenkins. It ensures infrastructure is managed as code while maintaining an efficient CI/CD pipeline.

