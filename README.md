# S3 Static Website Hosting with Terraform and Jenkins

## Overview
This project demonstrates how to deploy a static website using AWS S3, Terraform for infrastructure as code, and Jenkins for CI/CD automation. The infrastructure includes an S3 bucket for hosting, and Terraform state management using a remote S3 bucket with DynamoDB for state locking.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Terraform Setup](#terraform-setup)
- [Jenkins Automation](#jenkins-automation)
- [Deployment Workflow](#deployment-workflow)
- [Destroying the Infrastructure](#destroying-the-infrastructure)

## Prerequisites
- AWS account with IAM credentials.
- Terraform installed (v1.9.6 or later).
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
### Backend Configuration
Terraform state is stored in an S3 bucket and locked using a DynamoDB table.
```hcl
terraform {
  backend "s3" {
    bucket         = "pramod-terraform-state"
    key            = "mys3staticwebsite/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

### Infrastructure Configuration
- Creates an S3 bucket to host the static website.
- Enables static website hosting on the S3 bucket.
- Configures the bucket policy for public read access.

## Jenkins Automation
Jenkins is set up with a Multibranch Pipeline, triggering Terraform workflows based on Git branch events.

### Jenkinsfile
```groovy
pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-credentials')
        AWS_SECRET_ACCESS_KEY = credentials('aws-credentials')
        AWS_REGION            = "ap-south-1"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh '''
                    terraform init -backend-config="bucket=pramod-terraform-state" \
                                   -backend-config="key=mys3staticwebsite/terraform.tfstate" \
                                   -backend-config="region=ap-south-1" \
                                   -backend-config="encrypt=true" \
                                   -backend-config="dynamodb_table=terraform-lock"
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply on Merge') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def mergeCheck = sh(script: "git log --merges -n 1 --pretty=format:'%H'", returnStdout: true).trim()

                    if (mergeCheck) {
                        echo "Merge detected! Running terraform apply..."
                        sh 'terraform apply -auto-approve tfplan'
                        slackSend channel: '#jenkins', message: " *Deployment Successful!*\n\n*Job:* ${JOB_NAME} \n*Branch:* ${GIT_BRANCH} \n*Build Number:* ${BUILD_NUMBER} \n*View Job:* ${BUILD_URL}"
                    } else {
                        echo "No merge detected. Skipping terraform apply."
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend channel: '#jenkins', message: " *Deployment Successful!*\n\n*Job:* ${JOB_NAME} \n*Branch:* ${GIT_BRANCH} \n*Build Number:* ${BUILD_NUMBER} \n*View Job:* ${BUILD_URL}"
        }
        failure {
            slackSend channel: '#jenkins', message: " *Deployment Failed!*\n\n*Job:* ${JOB_NAME} \n*Branch:* ${GIT_BRANCH} \n*Build Number:* ${BUILD_NUMBER} \n*View Job:* ${BUILD_URL}"
        }
    }
}
```

## Deployment Workflow
1. **Push Changes to `us-1048` Branch:**
   - Developers work on the `us-1048` branch and push changes.
   - Jenkins runs Terraform `init` and `plan` but does not apply.
2. **Create Pull Request to `main` Branch:**
   - A PR is created to merge changes into `main`.
   - Review and approval are required before merging.
3. **Merge into `main` and Deploy:**
   - On merge, Jenkins detects the change and applies Terraform configurations.
   - S3 bucket is provisioned, and static website hosting is enabled.
   - A Slack notification is sent upon success or failure.

## Destroying the Infrastructure
To remove all resources created by Terraform:
```sh
terraform destroy -auto-approve
```
This will delete the S3 bucket, removing the static website.

## Conclusion
This project successfully automates S3 static website deployment using Terraform and Jenkins. It ensures infrastructure is managed as code while maintaining an efficient CI/CD pipeline.

