output "cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.demo.name
}

output "cluster_resource_group" {
  description = "Resource group containing the AKS cluster."
  value       = azurerm_kubernetes_cluster.demo.resource_group_name
}

output "cluster_id" {
  description = "Azure resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.demo.id
}