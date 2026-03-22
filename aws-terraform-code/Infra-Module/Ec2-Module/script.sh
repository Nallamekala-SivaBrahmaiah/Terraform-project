
#!/bin/bash
sudo apt update -y

# Java
sudo apt install openjdk-17-jdk -y

# Maven
sudo apt install maven -y

# Git
sudo apt install git -y

# docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo chmod 666 /var/run/docker.socket
sudo docker --version

# sonarqube
sudo docker pull sonarqube:latest
sudo docker run -dit --name sonarqube -p 9000:9000 sonarqube:latest


# Configure AWS CLI for ECR access
aws configure set default.region us-east-1
aws configure set default.output json
aws configure set aws_access_key_id <key>
aws configure set aws_secret_access_key <key>
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <ecr-repo-url>


# Trivy
sudo apt install wget gnupg -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt update -y
sudo apt install trivy -y
sudo chmod 666 /var/run/docker.socket
# unzip
sudo apt install unzip -y

# Jenkins & edit the path jemkins 8080 to 8081
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

sudo mkdir -p /var/lib/jenkins/.kube
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

# AWS CLI
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
unzip awscliv2.zip
sudo ./aws/install
aws --version

# kubectl - Fixed version
curl -LO 'https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl'
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client || true

# eksctl - Fixed download with retry
curl --silent --location --retry 3 'https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_linux_amd64.tar.gz' -o eksctl.tar.gz
tar -xzf eksctl.tar.gz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
rm eksctl.tar.gz
eksctl version

# Check for existing cluster and delete if exists
echo 'Checking for existing EKS cluster...'
if eksctl get cluster --name siva-cluster9381370 --region ap-south-1 &> /dev/null; then
  echo 'Existing cluster found. Deleting...'
  eksctl delete cluster --name siva-cluster9381370 --region ap-south-1 --wait
  echo 'Cluster deleted successfully'
else
  echo 'No existing cluster found'
fi

# Create new EKS cluster (this takes 10-15 minutes)
echo 'Creating EKS cluster siva-cluster9381370... (this will take 10-15 minutes)'
eksctl create cluster --name siva-cluster9381370 --region ap-south-1 --node-type m7i-flex.large  --zones ap-south-1a,ap-south-1b

# Create installation log
echo '=== Installation Complete ===' > /tmp/installation.log
date >> /tmp/installation.log
echo 'Docker:' >> /tmp/installation.log
docker --version >> /tmp/installation.log 2>&1
echo 'Java:' >> /tmp/installation.log
java --version >> /tmp/installation.log 2>&1
echo 'Maven:' >> /tmp/installation.log
mvn --version >> /tmp/installation.log 2>&1
echo 'kubectl:' >> /tmp/installation.log
kubectl version --client >> /tmp/installation.log 2>&1
echo 'AWS CLI:' >> /tmp/installation.log
aws --version >> /tmp/installation.log 2>&1
echo 'eksctl:' >> /tmp/installation.log
eksctl version >> /tmp/installation.log 2>&1
echo 'EKS cluster created successfully' >> /tmp/installation.log

