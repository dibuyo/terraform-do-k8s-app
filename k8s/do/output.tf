output "k8s_endpoint" {
  value       = digitalocean_kubernetes_cluster.k8s_main_cluster.endpoint
  description = "Endpoint K8s Digital Ocean"
}

variable "node_count" {
    type = number
    description = "Cantidad de Nodos Workers para K8s"
}