terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

locals {
  private_key_file = ".terraform.pem"
}

#---------------------------------------
# Create and upload keypair
#---------------------------------------

# Não precisas deste bloco se já tens a tua chave RSA
# resource "tls_private_key" "key" {
#   algorithm = "RSA"
#
#   provisioner "local-exec" {
#     command = "echo \"$PRIVATE_KEY\" > ${local.private_key_file} && chmod 600 ${local.private_key_file}"
#
#     environment = {
#       PRIVATE_KEY = tls_private_key.key.private_key_pem
#     }
#   }
# }

# resource "random_string" "keyname" {
#   length  = 5
#   special = false
#   upper   = false
#   number  = false
# }

resource "openstack_compute_keypair_v2" "keypair1" {
  name       = "nellkey"
  public_key = file("/home/nelminha/.ssh/id_rsa.pub")
}

# Configure the OpenStack Provider
provider "openstack" {
  auth_url          = var.auth_url
  tenant_name       = "iac-pic"
  user_name         = var.username
  password          = var.password
  region            = "RegionT"
  project_domain_name = var.project_domain_name
  user_domain_name    = var.user_domain_name
}
