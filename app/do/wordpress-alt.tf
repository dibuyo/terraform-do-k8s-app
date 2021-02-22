resource "kubernetes_persistent_volume_claim" "wordpress_alt_volume_claim" {
  metadata {
    name = "wordpress-alt-pv-claim"
    namespace = "app"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "wordpress_alt" {

  metadata {
    name = "wordpress-alt"
    labels = {
      app = "wordpress-alt"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "wordpress-alt"
      }
    }

    template {

      metadata {
        labels = {
          app = "wordpress-alt"
        }
      }

      spec {

        container {
          image = "wordpress"
          name  = "wordpress-alt"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/var/www/html"
            name = "wordpress-persistent-html"
          }

          env {
            name = "WORDPRESS_DB_HOST"
            value = "mysql.${var.mysql_namespace}.svc.cluster.local."
          }
          
          env {
            name = "WORDPRESS_DB_USER"
            value = var.mysql_usr_wordpress_alt
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value = var.mysql_pwd_wordpress_alt
          }

          env {
            name = "WORDPRESS_DB_NAME"
            value = "academiaperioperatoria_wpdb"
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
            claim_name = kubernetes_persistent_volume_claim.wordpress_alt_volume_claim.metadata.0.name
          } 
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress_alt" {
  metadata {
    name = "wordpress-alt"
    annotations = {
        name = "wordpress-alt-service"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.wordpress_alt.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "wordpress_alt_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "wordpress-academia"
            namespace = "app"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`${var.domain_alt}`) || Host(`blog.${var.domain_alt}`) || Host(`www.${var.domain_alt}`)"
              
              services = [{
                name = kubernetes_service.wordpress_alt.metadata[0].name
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
                sans = [ "blog.${var.domain_alt}", "www.${var.domain_alt}" ]
              }]
            }
        }
    }
}