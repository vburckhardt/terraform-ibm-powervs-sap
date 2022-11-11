locals {
  ibm_powervs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "tok04"    = "tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "tor"
    "osa21"    = "osa"
    "sao01"    = "sao"
    "mon01"    = "mon"
  }

  ibm_powervs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "tok04"    = "jp-tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "ca-tor"
    "osa21"    = "jp-osa"
    "sao01"    = "br-sao"
    "mon01"    = "ca-tor"
  }
}

#####################################################
# PVS SAP Instance Deployment example for SAP SYSTEM with new private network
#####################################################

# There are discrepancies between the region inputs on the powervs terraform resource, and the vpc ("is") resources
provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-is"
  region           = lookup(local.ibm_powervs_zone_cloud_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

#####################################################
# Create a new PowerVS infrastructure from scratch
#####################################################

locals {
  powervs_workspace_name = "${var.prefix}-${var.powervs_zone}-${var.powervs_workspace_name}"
  powervs_sshkey_name    = "${var.prefix}-${var.powervs_zone}-${var.powervs_sshkey_name}"
}

# Security Notice
# The private key generated by this resource will be stored unencrypted in your Terraform state file.
# Use of this resource for production deployments is not recommended.
# Instead, generate a private key file outside of Terraform and distribute it securely to the system where
# Terraform will be run.

resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  provider   = ibm.ibm-is
  name       = local.powervs_sshkey_name
  public_key = trimspace(tls_private_key.tls_key.public_key_openssh)
}

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.2"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "power_infrastructure" {
  # Replace "main" with a GIT release version to lock into a specific release
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure.git?ref=v5.0.0"

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = module.resource_group.resource_group_name
  powervs_workspace_name      = local.powervs_workspace_name
  tags                        = var.resource_tags
  powervs_sshkey_name         = local.powervs_sshkey_name
  ssh_public_key              = ibm_is_ssh_key.ssh_key.public_key
  ssh_private_key             = trimspace(tls_private_key.tls_key.private_key_openssh)
  access_host_or_ip           = var.access_host_or_ip
  powervs_management_network  = var.powervs_management_network
  powervs_backup_network      = var.powervs_backup_network
  transit_gateway_name        = var.transit_gateway_name
  reuse_cloud_connections     = var.reuse_cloud_connections
  cloud_connection_count      = var.cloud_connection_count
  cloud_connection_speed      = var.cloud_connection_speed
  cloud_connection_gr         = var.cloud_connection_gr
  cloud_connection_metered    = var.cloud_connection_metered
  squid_config                = var.squid_config
  dns_forwarder_config        = var.dns_forwarder_config
  ntp_forwarder_config        = var.ntp_forwarder_config
  nfs_config                  = var.nfs_config
  perform_proxy_client_setup  = var.perform_proxy_client_setup
}

locals {
  powervs_sap_network_name          = "${var.prefix}-net"
  powervs_share_number_of_instances = var.create_separate_fs_share ? 1 : 0
  additional_networks               = [var.powervs_management_network["name"], var.powervs_backup_network["name"]]
}

#####################################################
# Deploy SAP systems
#####################################################

module "sap_systems" {
  depends_on = [module.power_infrastructure]
  source     = "../../"

  powervs_zone                   = var.powervs_zone
  powervs_resource_group_name    = module.resource_group.resource_group_name
  powervs_workspace_name         = local.powervs_workspace_name
  powervs_sshkey_name            = local.powervs_sshkey_name
  powervs_sap_network            = { "name" = local.powervs_sap_network_name, "cidr" = var.powervs_sap_network_cidr }
  powervs_additional_networks    = local.additional_networks
  powervs_cloud_connection_count = var.cloud_connection_count

  powervs_share_instance_name        = var.sap_share_instance_config["hostname"]
  powervs_share_image_name           = var.sap_share_instance_config["os_image_name"]
  powervs_share_number_of_instances  = local.powervs_share_number_of_instances
  powervs_share_number_of_processors = var.sap_share_instance_config["number_of_processors"]
  powervs_share_memory_size          = var.sap_share_instance_config["memory_size"]
  powervs_share_cpu_proc_type        = var.sap_share_instance_config["cpu_proc_type"]
  powervs_share_server_type          = var.sap_share_instance_config["server_type"]
  powervs_share_storage_config       = var.sap_share_storage_config

  powervs_hana_instance_name             = var.sap_hana_instance_config["hostname"]
  powervs_hana_image_name                = var.sap_hana_instance_config["os_image_name"]
  powervs_hana_sap_profile_id            = var.sap_hana_instance_config["sap_profile_id"]
  powervs_hana_custom_storage_config     = var.sap_hana_custom_storage_config
  powervs_hana_additional_storage_config = var.sap_hana_additional_storage_config

  powervs_netweaver_instance_name        = var.sap_netweaver_instance_config["hostname"]
  powervs_netweaver_image_name           = var.sap_netweaver_instance_config["os_image_name"]
  powervs_netweaver_number_of_instances  = var.sap_netweaver_instance_config["number_of_instances"]
  powervs_netweaver_number_of_processors = var.sap_netweaver_instance_config["number_of_processors"]
  powervs_netweaver_memory_size          = var.sap_netweaver_instance_config["memory_size"]
  powervs_netweaver_cpu_proc_type        = var.sap_netweaver_instance_config["cpu_proc_type"]
  powervs_netweaver_server_type          = var.sap_netweaver_instance_config["server_type"]
  powervs_netweaver_storage_config       = var.sap_netweaver_storage_config

  configure_os          = var.configure_os
  os_image_distro       = var.os_image_distro
  access_host_or_ip     = var.access_host_or_ip
  ssh_private_key       = trimspace(tls_private_key.tls_key.private_key_openssh)
  proxy_host_or_ip_port = var.squid_config["server_host_or_ip"]
  ntp_host_or_ip        = var.ntp_forwarder_config["server_host_or_ip"]
  dns_host_or_ip        = var.dns_forwarder_config["server_host_or_ip"]
  nfs_path              = var.nfs_config["nfs_directory"]
  nfs_client_directory  = var.nfs_client_directory
  sap_domain            = var.sap_domain
}
