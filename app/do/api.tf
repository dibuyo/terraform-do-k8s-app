resource "kubernetes_config_map" "myjourney_api_config" {
  metadata {
    name = "myjourney-api-config"
    namespace = "app"
  }

  data = {
    ".env" = file("./${path.module}/files/env.api")
  }
}

resource "kubernetes_deployment" "myjourney_api" {

  metadata {
    name = "myjourney-api"
    labels = {
      app = "myjourney-api"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "myjourney-api"
      }
    }

    template {

      metadata {
        labels = {
          app = "myjourney-api"
        }
      }

      spec {

        container {
          image = "registry.digitalocean.com/myjourney-apps/api-1"
          name  = "myjourney-api"

           volume_mount {
               mount_path = "/usr/src/api/.env"
               sub_path = ".env"
               name = "myjourney-api-config-path"
               read_only = true
           }

          port {
            container_port = 3000
          }
        }

        volume {
            name = "myjourney-api-config-path"
            config_map {
                name = "myjourney-api-config"
            }
        }
      }
    }
  }
}

resource "kubernetes_service" "myjourney-api" {
  metadata {
    name = "myjourney-api"
    annotations = {
        name = "myjourney-api"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.myjourney_api.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "myjourney_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "myjourney-api"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`api.${var.domain}`)"
              
              services = [{
                name = "myjourney-api"
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