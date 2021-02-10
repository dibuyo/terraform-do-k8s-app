resource "kubernetes_persistent_volume_claim" "pgadmin_volume_claim" {
  metadata {
    name = "pgadmin-pv-claim"
    namespace = "app"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "pgadmin" {

    metadata {
        name = "pgadmin"
        labels = {
            app = "pgadmin"
        }
        namespace = "app"
    }

    spec {

        replicas = 1
        selector {
        match_labels = {
            app = "pgadmin"
        }
        }

        strategy {
            type = "Recreate"
        }

        template {

        metadata {
            labels = {
                app = "pgadmin"
            }
        }

            spec {
                container {
                image = "dpage/pgadmin4:latest"
                name  = "pgadmin"

                    /*liveness_probe {
                        http_get {
                            path = "/-/ping"
                            port = "http"
                        }
                        initial_delay_seconds = 60
                    }*/

                    volume_mount {
                        mount_path = "/root/.pgadmin"
                        name = "pgadmin-config-path"
                    }

                    #security_context {
                        #run_as_user = 10001
                        #fs_group = 10001
                    #}

                    env {
                        name = "PGADMIN_DEFAULT_EMAIL"
                        value = var.pgadmin_default_email
                    }

                    env {
                        name = "PGADMIN_DEFAULT_PASSWORD"
                        value = var.pgadmin_default_password
                    }

                    args = []
                }

                volume {
                    name = "pgadmin-config-path"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.pgadmin_volume_claim.metadata[0].name
                    } 
                }
            }
        }
    }
}

resource "kubernetes_service" "pgadmin" {
  metadata {
    name = "pgadmin"
    annotations = {
        name = "pgadmin"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.pgadmin.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "pgadmin"
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "pgadmin_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "pgadmin"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`pgadmin.${var.domain}`)"
              
              services = [{
                name = "pgadmin"
                port = 80
              }]

              middlewares = [{
                name = "redirect-https"
                namespace = "ingress"
              }]
            }]

            tls = {
              certResolver = "le"
            }
        }
    }
}