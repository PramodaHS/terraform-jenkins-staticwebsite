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
