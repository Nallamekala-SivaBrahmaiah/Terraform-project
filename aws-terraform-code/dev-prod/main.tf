

# ===============================
# s3 and backend block
# ===============================
module "s3_bucket" {
  source      = "../Infra-Module/S3-Module"
  bucket_name = "my-tf-test-bucket-123458"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# ===============================
# VPC Module
# ===============================
module "vpc" {
  source     = "../Infra-Module/Vpc-Module"
  cidr_block = "10.2.0.0/16"
  vpc_name   = "siva-vpc02"
}

# ===============================
# Subnet Module
# ===============================
module "subnet" {
  source              = "../Infra-Module/Subnet-Module"
  vpc_id              = module.vpc.vpc_id
  cidr_block          = "10.2.1.0/24"
  availability_zone   = "ap-south-1a"
  public_ip_on_launch = true
  subnet_name         = "siva-subnet02"
}

# ===============================
# Internet Gateway Module
# ===============================
module "internet_gateway" {
  source                = "../Infra-Module/Inter-Module"
  vpc_id                = module.vpc.vpc_id
  internet_gateway_name = "siva-internet-gateway02"

}

# ===============================
# Default Route Table Module
# ===============================
module "route_table" {
  source           = "../Infra-Module/Route-Module"
  vpc_id           = module.vpc.vpc_id
  igw_id           = module.internet_gateway.internet_gateway_id
  route_table_name = "siva-route-table02"
  subnet_id        = module.subnet.subnet_id
}

# ===============================
# Security Group Module
# ===============================
module "security_group" {
  source  = "../Infra-Module/Secutity-Module"
  vpc_id  = module.vpc.vpc_id
  sg_name = "siva-allow-all-sg01"
}

# ===============================
# ECR Module
# ===============================
module "ecr" {
  source               = "../Infra-Module/Ecr-Module"
  ecr_repository_name  = "siva-ecr-repository02"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

# ===============================
# EC2 Module
# ===============================
module "ec2" {
  source                = "../Infra-Module/Ec2-Module"
  ami_id                = "ami-05d2d839d4f73aafb"
  instance_type         = "m7i-flex.large"
  key_name              = "siva01"
  instance_profile_name = "awscluster-profile"
  role                  = "siva-role"
  subnet_id             = module.subnet.subnet_id
  security_group_ids    = [module.security_group.sg_id]
  iam_instance_profile  = module.ec2.instance_profile_name


  tags = {
    Name = "siva-instance02"
  }
  ec2_instance_name = "siva-ec3-instance02"

}
