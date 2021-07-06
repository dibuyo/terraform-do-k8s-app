resource "kubernetes_deployment" "metabase" {

  metadata {
    name = "metabase"
    labels = {
      app = "metabase"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "metabase"
      }
    }

    template {

      metadata {
        labels = {
          app = "metabase"
        }
      }

      spec {

        container {
          image = "metabase/metabase:v0.39.1"
          name  = "metabase"

          port {
            container_port = 3000
          }

          /*volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name = "mysql-initdb"
          }*/

          env {
            name = "MB_JETTY_HOST"
            value = "0.0.0.0"
          }
          
          env {
            name = "MB_JETTY_PORT"
            value = 3000
          }

          env {
            name = "MB_DB_TYPE"
            value = "mysql"
          }

          env {
            name = "MB_DB_HOST"
            value = "mysql.${var.mysql_namespace}.svc.cluster.local."
          }

          env {
            name = "MB_DB_PORT"
            value = 3306
          }

          env {
            name = "MB_DB_DBNAME"
            value = var.metabase_db
          }

          env {
            name = "MB_DB_USER"
            value = var.metabase_usr
          }

          env {
            name = "MB_DB_PASS"
            value = var.metabase_pwd
          }

          args = [
          ]

          resources {
            limits {
              cpu    = "1"
              memory = "1024Mi"
            }
            requests {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "metabase" {
  metadata {
    name = "metabase"
    annotations = {
        name = "metabase-service"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.metabase.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "metabase_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "metabase"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`${var.metabase_url}`)"
              
              services = [{
                name = "metabase"
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