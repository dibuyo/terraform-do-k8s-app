resource "kubernetes_config_map" "wordpress_config" {
  metadata {
    name = "wordpress-config"
    namespace = "app"
  }

  data = {
    ".htaccess" = file("./${path.module}/files/wordpress.htaccess")
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_volume_claim" {
  metadata {
    name = "wordpress-pv-claim"
    namespace = "app"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "wordpress" {

  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {

      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {

        container {
          image = "wordpress"
          name  = "wordpress"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/var/www/html"
            name = "wordpress-persistent-html"
          }

          volume_mount {
            mount_path = "/var/www/html/.htaccess"
            name = "htaccess-file"
            sub_path = ".htaccess"
          }

          /*volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name = "mysql-initdb"
          }*/

          env {
            name = "WORDPRESS_DB_HOST"
            value = "mysql.${var.mysql_namespace}.svc.cluster.local."
          }
          
          env {
            name = "WORDPRESS_DB_USER"
            value = var.mysql_usr_wordpress
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value = var.mysql_pwd_wordpress
          }

          env {
            name = "WORDPRESS_DB_NAME"
            value = "myjourney_wpdb"
          }

          args = [
          ]

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

        }

        volume {
          name = "wordpress-persistent-html"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress_volume_claim.metadata.0.name
          } 
        }

        volume {
            name = "htaccess-file"
            config_map {
                name = "wordpress-config"
            }
        }

      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
    annotations = {
        name = "wordpress-service"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.wordpress.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "wordpress_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "wordpress"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`${var.domain}`) || Host(`blog.${var.domain}`) || Host(`www.${var.domain}`)"
              
              services = [{
                name = "wordpress"
                port = 80
              }]

              middlewares = [{
                name = "redirect-https"
                namespace = "ingress"
              }]
            }]

            tls = {
              certResolver = "le"
              domains = [{
                main = var.domain
                sans = [ "blog.${var.domain}", "www.${var.domain}" ]
              }]
            }
        }
    }
}