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
    node_count = 1
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
    environment = "dev"
    managed-by  = "terraform"
  }
}

resource "azapi_resource" "release_namespace" {
  type      = "Microsoft.ContainerService/managedClusters/managedNamespaces@2025-10-01"
  name      = "aks-release-demo"
  parent_id = azurerm_kubernetes_cluster.demo.id
  location  = azurerm_kubernetes_cluster.demo.location

  body = {
    properties = {
      adoptionPolicy = "Never"
      deletePolicy   = "Delete"
    }
  }
}

resource "azurerm_role_assignment" "release_namespace_writer" {
  scope                = azapi_resource.release_namespace.id
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
}