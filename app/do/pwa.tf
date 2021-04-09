resource "kubernetes_config_map" "myjourney_pwa_config" {
  metadata {
    name = "myjourney-pwa-config"
    namespace = "app"
  }

  data = {
    ".env" = file("./${path.module}/files/env.pwa")
  }
}

resource "kubernetes_deployment" "myjourney_pwa" {

  metadata {
    name = "myjourney-pwa"
    labels = {
      app = "myjourney-pwa"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "myjourney-pwa"
      }
    }

    template {

      metadata {
        labels = {
          app = "myjourney-pwa"
        }
      }

      spec {

        container {
          stdin = true
          image = "registry.digitalocean.com/myjourney-apps/pwa:test"
          image_pull_policy = "Always"
          name  = "myjourney-pwa"

           volume_mount {
               mount_path = "/usr/src/pwa/.env"
               sub_path = ".env"
               name = "myjourney-pwa-config-path"
               read_only = true
           }

          env {
            name = "REACT_APP_BASE_URL"
            value = "https://api.${var.domain}/api"
          }

          env {
            name = "REACT_APP_PWA_URL"
            value = "https://app.${var.domain}"
          }

          env {
            name = "SENTRY_DSN"
            value = "https://96d6618eda1a4976b0406244ade73fe7@o564212.ingest.sentry.io/5706744"
          }
          
          env {
            name = "REACT_APP_PUSHER_INSTANCE_ID"
            value = "924714a1-6341-4a66-af55-1936cdc384d0"
          }

          port {
            container_port = 80
          }
        }

        volume {
            name = "myjourney-pwa-config-path"
            config_map {
                name = "myjourney-pwa-config"
            }
        }
      }
    }
  }
}

resource "kubernetes_service" "myjourney_pwa" {
  metadata {
    name = "myjourney-pwa"
    annotations = {
        name = "myjourney-pwa"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.myjourney_pwa.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "myjourney_pwa_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "myjourney-pwa"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`app.${var.domain}`)"
              
              services = [{
                name = "myjourney-pwa"
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