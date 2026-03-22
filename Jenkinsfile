pipeline {
    agent any

environment {
    AWS_REGION = "ap-south-1"
    ECR_REPO = "538449086740.dkr.ecr.ap-south-1.amazonaws.com/siva-elastic-ecr"
    ECR_REGISTRY = "538449086740.dkr.ecr.ap-south-1.amazonaws.com"
    IMAGE_TAG = "${BUILD_NUMBER}"
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
            withSonarQubeEnv('sona-rqube') {
                sh '''
                mvn sonar:sonar \
                -Dsonar.projectKey=terraform-project \
                -Dsonar.projectName=terraform-project \
                -Dsonar.sources=. \
                '''
            }
        }
    }

    stage('Login to ECR') {
        steps {
            sh '''
            aws ecr get-login-password --region $AWS_REGION \
            | docker login --username AWS --password-stdin $ECR_REGISTRY
            '''
        }
    }

    stage('Build Docker Images') {
        steps {
            sh '''
            docker build -t $ECR_REPO:frontend-$IMAGE_TAG frontend/
            '''
        }
    }

    stage('Push Images to ECR') {
        steps {
            sh '''
            docker push $ECR_REPO:frontend-$IMAGE_TAG
            '''
        }
    }

    stage('Trivy Security Scan') {
        steps {
            sh '''
            echo "Scanning frontend image..."
            trivy image --severity HIGH,CRITICAL $ECR_REPO:frontend-$IMAGE_TAG || true
            '''
        }
    }

    stage('Deploy to Kubernetes') {
        steps {
            sh '''
            export KUBECONFIG=/home/ubuntu/.kube/config
            kubectl set image deployment/frontend frontend=$ECR_REPO:frontend-$IMAGE_TAG
            kubectl apply -f jenkins.yaml
            '''
        }
    }
}

}
