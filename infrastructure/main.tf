resource "azurerm_kubernetes_cluster" "demo" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
  dns_prefix          = var.cluster_name
  sku_tier            = "Free"

  local_account_disabled           = true
  role_based_access_control_enabled = true

  node_provisioning_profile {
    mode = "Manual"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = var.node_vm_size
    max_pods   = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
  }

  tags = {
    project     = "aks-release-toolkit"
    environment = "demo"
    managed-by  = "terraform"
  }
}