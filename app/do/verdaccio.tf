resource "kubernetes_config_map" "verdaccio_config" {
  metadata {
    name = "verdaccio-config"
    namespace = "app"
  }

  data = {
    "config.yaml" = file("./${path.module}/files/verdaccio.yaml")
  }
}

resource "kubernetes_secret" "verdaccio_basic_auth" {
  metadata {
    name = "verdaccio-basic-auth"
    namespace = "app"
  }

  data = {
    auth = "devops:$apr1$75flgnQt$at5kv/fCYow/jx5unElBm."
  }
}

resource "kubernetes_persistent_volume_claim" "verdaccio_volume_claim" {
  
  metadata {
    name = "verdaccio-pv-claim"
    namespace = "app"
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "4Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "verdaccio" {

    metadata {
        name = "verdaccio"
        labels = {
        app = "verdaccio"
        }
        namespace = "app"
    }

    spec {

        replicas = 1
        selector {
        match_labels = {
            app = "verdaccio"
        }
        }

        strategy {
            type = "Recreate"
            #rollingUpdate = null
        }

        template {

          metadata {
              labels = {
              app = "verdaccio"
              }
          }

          spec {
              container {
              image = "verdaccio/verdaccio"
              name  = "verdaccio"

                  port {
                      container_port = 4873
                      name = "http"
                  }

                  /*liveness_probe {
                      http_get {
                          path = "/-/ping"
                          port = "http"
                      }
                      initial_delay_seconds = 60
                  }*/

                  readiness_probe {
                      http_get {
                          path = "/-/ping"
                          port = "http"
                      }
                      initial_delay_seconds = 60
                  }

                  volume_mount {
                      mount_path = "/verdaccio/storage"
                      name = "verdaccio-persistent-storage"
                      read_only = false
                  }

                  volume_mount {
                      mount_path = "/verdaccio/conf"
                      name = "verdaccio-config-path"
                      read_only = true
                  }

                  volume_mount {
                      mount_path = "/verdaccio/conf/htpasswd"
                      name = "verdaccio-htaccess"
                      read_only = true
                  }

                  env {
                      name = "VERDACCIO_PORT"
                      value = 4873
                  }

                  args = []
              }

              security_context {
                fs_group = "101"
                run_as_user = 10001
              }

              volume {
                  name = "verdaccio-persistent-storage"
                  persistent_volume_claim {
                      claim_name = "verdaccio-pv-claim"
                  } 
              }

              volume {
                  name = "verdaccio-config-path"
                  config_map {
                      name = "verdaccio-config"
                  }
              }
              volume {
                  name = "verdaccio-htaccess"
                  secret {
                      secret_name = "verdaccio-basic-auth"
                  }
              }
          }
        }
    }
}

resource "kubernetes_service" "verdaccio" {
  metadata {
    name = "verdaccio"
    annotations = {
        name = "verdaccio-service"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.verdaccio.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "verdaccio"
      port        = 80
      target_port = 4873
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "verdaccio_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "verdaccio"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`npm.${var.domain}`)"
              
              services = [{
                name = "verdaccio"
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