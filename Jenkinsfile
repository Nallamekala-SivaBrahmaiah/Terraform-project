pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "779679300583.dkr.ecr.ap-south-1.amazonaws.com/siva-ecr-repository02"
        ECR_REGISTRY = "779679300583.dkr.ecr.ap-south-1.amazonaws.com"
        IMAGE_TAG = "siva"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Nallamekala-SivaBrahmaiah/Terraform-project.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Code Scan') {
            steps {
                withSonarQubeEnv('sonar-qube') {
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=terraform-project \
                        -Dsonar.projectName=terraform-project \
                        -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin $ECR_REGISTRY
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $ECR_REPO:app-$IMAGE_TAG .
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                    docker push $ECR_REPO:app-$IMAGE_TAG
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    echo "Scanning frontend image..."
                    trivy image --severity HIGH,CRITICAL $ECR_REPO:app-$IMAGE_TAG || true
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                    sh '''
                        kubectl apply -f jenkins.yaml
                    '''
                }
            }
        }

    }
