resource "kubernetes_namespace" "namespace_app" {

  metadata {
    annotations = {
      name = "app"
      "linkerd.io/inject" = "enabled"
    }

    labels = {
      
    }

    name = "app"
  }
}

/*resource "kubernetes_network_policy" "network_policy_app" {
  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace.namespace_app.metadata[0].name
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = { "linkerd.io/is-control-plane" = "true" }
        }
      }

      from {
        pod_selector {}
      }
    }

    policy_types = ["Ingress"]
  }
}
*/