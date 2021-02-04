resource "digitalocean_kubernetes_cluster" "k8s_main_cluster" {
  name   = "k8s-19-nyc1-my-journey"
  region = "nyc1"
  version = "1.19.3-do.3"

  node_pool {
    name       = "pool-ogjookpq8"
    size       = "s-2vcpu-4gb"
    node_count = var.node_count
  }
}

provider "kubernetes" {
  load_config_file = false
  host             = digitalocean_kubernetes_cluster.k8s_main_cluster.endpoint
  token            = digitalocean_kubernetes_cluster.k8s_main_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s_main_cluster.kube_config[0].cluster_ca_certificate
  )
}