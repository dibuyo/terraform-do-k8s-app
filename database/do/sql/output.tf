output "datastore_namespace" {
  value = kubernetes_namespace.namespace_datastore.metadata[0].name
}