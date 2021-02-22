resource "kubernetes_namespace" "namespace_datastore" {

  metadata {
    annotations = {
      name = "datastore"
    }

    labels = { 
    }

    name = "datastore"
  }
}