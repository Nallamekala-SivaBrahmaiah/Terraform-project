module "rg" {
  source   = "../Infra-Module/RG-Module"
  rg_name  = "siva-rg"
  loc_name = "japan east"
}

module "acr" {
  source     = "../Infra-Module/Acr-Module"
  acr_name   = "awsazureclouds"
  rg_name    = module.rg.rg_name
  loc_name   = module.rg.rg_location
  depends_on = [module.rg]
}
module "eks" {
  source       = "../Infra-Module/Eks-Module"
  cluster_name = "testcluster01"
  rg_name      = module.rg.rg_name
  loc_name     = module.rg.rg_location
  dns_prefix   = "exampleaks1"
  acr_id       = module.acr.acr_id
  depends_on   = [module.acr]
}
module "vnet" {
  source        = "../Infra-Module/Vnet-Module"
  vnet_name     = "vnet01"
  address_space = ["10.1.0.0/16"]
  rg_name       = module.rg.rg_name
  loc_name      = module.rg.rg_location
  depends_on    = [module.eks]
}
module "subnet" {
  source           = "../Infra-Module/Subnet-Module"
  vnet_name        = module.vnet.vnet_name
  rg_name          = module.rg.rg_name
  address_prefixes = ["10.1.1.0/24"]
  subnet_name      = "subnet01"
  depends_on       = [module.vnet]
}

module "public" {
  source            = "../Infra-Module/Public-Module"
  pip_name          = "public01"
  allocation_method = "Static"
  rg_name           = module.rg.rg_name
  loc_name          = module.rg.rg_location
  depends_on        = [module.subnet]
}
module "nic" {
  source       = "../Infra-Module/Nic-Module"
  nic_name     = "nic01"
  subnet_id    = module.subnet.subnet_id
  public_ip_id = module.public.public_ip_id
  rg_name      = module.rg.rg_name
  loc_name     = module.rg.rg_location
  depends_on   = [module.public]
}
module "nsg" {
  source     = "../Infra-Module/Nsg-Module"
  nsg_name   = "nsg01"
  rg_name    = module.rg.rg_name
  loc_name   = module.rg.rg_location
  nic_id     = module.nic.nic_id
  depends_on = [module.nic]

}
module "ec2" {
  source   = "../Infra-Module/Ec2-Module"
  vm_name  = "ec2-instance"
  rg_name  = module.rg.rg_name
  loc_name = module.rg.rg_location
  nic_id   = module.nic.nic_id

  admin_username = "siva"
  admin_password = "Nsbyadav@143"

  public_ip = module.public.public_ip_address
}

