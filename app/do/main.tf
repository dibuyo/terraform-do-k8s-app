resource "kubernetes_namespace" "namespace-app" {

  metadata {
    annotations = {
      name = "app"
    }

    labels = {
      
    }

    name = "app"
  }
}