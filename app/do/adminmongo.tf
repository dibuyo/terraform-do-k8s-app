resource "kubernetes_config_map" "adminmongo_config" {
  metadata {
    name = "adminmongo-config"
    namespace = "app"
  }

  data = {
    "app.json" = file("./${path.module}/files/adminmongo.app.json")
  }
}

resource "kubernetes_deployment" "adminmongo" {

  metadata {
    name = "adminmongo"
    labels = {
      app = "adminmongo"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "adminmongo"
      }
    }

    template {

      metadata {
        labels = {
          app = "adminmongo"
        }
      }

      spec {

        container {
          image = "adicom/admin-mongo"
          name  = "adminmongo"

          port {
            container_port = 80
          }

          env {
            name = "PORT"
            value = "80"
          }
          
          env {
            name = "HOST"
            value = "localhost"
          }

          env {
            name = "PASSWORD"
            value = var.auth_password
          }

          /*env {
            name = "MB_DB_HOST"
            value = "mysql.${var.mysql_namespace}.svc.cluster.local."
          }*/

          env {
            name = "CONN_NAME"
            value = "MyJourney Mongo"
          }

          env {
            name = "DB_HOST"
            value = "myjourney-mongodb.datastore.svc.cluster.local."
          }

          args = [
          ]

            volume_mount {
                mount_path = "/config/app.json"
                name = "adminmongo-config-path"
                sub_path = "app.json"
            }
        }

        volume {
            name = "adminmongo-config-path"
            config_map {
                name = "adminmongo-config"
            }
        }
      }
    }
  }
}

resource "kubernetes_service" "adminmongo" {
  metadata {
    name = "adminmongo"
    annotations = {
        name = "adminmongo-service"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.adminmongo.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "adminmongo_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "adminmongo"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`mgadmin.${var.domain}`)"
              
              services = [{
                name = "adminmongo"
                port = 80
              }]

              middlewares = [{
                name = "basic-auth"
                namespace = "ingress"
              },{
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