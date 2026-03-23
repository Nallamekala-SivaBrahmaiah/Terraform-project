
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
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.socket
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

# sonarqube
sudo docker pull sonarqube:latest
sudo docker run -dit --name sonarqube -p 9000:9000 sonarqube:latest



# Trivy
sudo apt install wget gnupg -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt update -y
sudo apt install trivy -y


# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl


# Logging aks"
az login --service-principal \
  -u $AZURE_CLIENT_ID \
  -p $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID

# Getting AKS Credentials 
az aks get-credentials --resource-group siva-rg --name testcluster01 --overwrite-existing

# Verifying Kubernetes Cluster 
kubectl get nodes