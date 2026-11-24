variable "resource_group_name" {
  description = "Existing Azure resource group for the AKS cluster."
  type        = string
  default     = "rg-aks-release-demo"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-release-demo"
}

variable "node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}