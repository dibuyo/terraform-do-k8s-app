provider "kubernetes" {}

provider "kubernetes-alpha" {
    config_path = "~/.kube/config" // path to kubeconfig
}


resource "kubernetes_config_map" "traefik-config-map" {
  metadata {
    name = "traefik-ingress-controller"
    namespace = "ingress"
  }

  data = {
    "traefik.yaml" = file("${path.module}/config/traefik.yaml")
    "traefik.toml" = file("${path.module}/config/traefik.toml")
  }
}

resource "kubernetes_service_account" "traefik" {
  metadata {
    name = "traefik"
    namespace = "ingress"
  }
  automount_service_account_token = false
}

resource "kubernetes_manifest" "traefil-custom-manifest" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "ingressroutes.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "IngressRoute"
                plural = "ingressroutes"
                singular = "ingressroute"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-router-tcp" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "ingressroutetcps.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "IngressRouteTCP"
                plural = "ingressroutetcps"
                singular = "ingressroutetcp"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-tls-store" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "tlsstores.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "TLSStore"
                plural = "tlsstores"
                singular = "tlsstore"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-router-udp" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "ingressrouteudps.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "IngressRouteUDP"
                plural = "ingressrouteudps"
                singular = "ingressrouteudp"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-middleware" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "middlewares.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "Middleware"
                plural = "middlewares"
                singular = "middleware"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-tls-options" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "tlsoptions.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "TLSOption"
                plural = "tlsoptions"
                singular = "tlsoption"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-service" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "traefikservices.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "TraefikService"
                plural = "traefikservices"
                singular = "traefikservice"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_manifest" "traefil-custom-manifest-server-transport" {
    provider = kubernetes-alpha

    manifest =  {
        apiVersion = "apiextensions.k8s.io/v1beta1"
        kind = "CustomResourceDefinition"
        metadata = {
            name = "serverstransports.traefik.containo.us"
            namespace = "ingress"
        }
        spec = {
            group = "traefik.containo.us"
            version  = "v1alpha1"
            names = {
                kind = "ServersTransport"
                plural = "serverstransports"
                singular = "serverstransport"
            }
            scope = "Namespaced"
        }
    }
}

resource "kubernetes_cluster_role" "traefil-custom-cluster-role" {
  metadata {
    name = "traefik"
  }

  rule {
    api_groups = [""]
    resources  = ["pods","services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses","ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["traefik.containo.us"]
    resources  = ["ingressroutes", "ingressroutetcps", "ingressrouteudps", "middlewares", "tlsoptions", "tlsstores", "traefikservices", "serverstransports"]
    verbs      = ["get", "list", "watch"]
  }

}

resource "kubernetes_cluster_role_binding" "traefil-cluster-role-binding" {
  metadata {
    name = "traefik"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "traefik"
    namespace = "ingress"
    #api_group = "rbac.authorization.k8s.io"
  }
}

#resource "kubernetes_manifest" "traefil-custom-manifest-v2" {
#    provider = kubernetes-alpha
#    manifest = "${file("${path.module}/manifests/traefik.yaml")}"
#}

resource "kubernetes_namespace" "namespace_igress" {
  metadata {
    annotations = {
      name = "ingress-control"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "ingress"
  }
}

resource "kubernetes_persistent_volume_claim" "traefik-volume-claim" {
  metadata {
    name = "traefik-acme-disk"
    namespace = "ingress"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    #volume_name = "${kubernetes_persistent_volume.example.metadata.0.name}"
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name = "traefik-ingress-control"
    labels = {
      App = "TraefikIngressControl"
    }
    namespace = "ingress"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        App = "TraefikIngressControl"
      }
    }
    template {

      metadata {
        labels = {
          App = "TraefikIngressControl"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.traefik.metadata.0.name
        automount_service_account_token = true

        container {
          image = "traefik:2.4"
          name  = "traefik"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/config"
            name = "config"
          }

          volume_mount {
            mount_path = "/acme"
            name = "acme"
          }

          env {
            name = "DO_AUTH_TOKEN"
            value = var.do_token
          }

          args = [
              "--api.dashboard=true",
              "--accesslog=true",
              "--accesslog.filepath=/var/log/traefik/access.v2.log",
              "--accesslog.bufferingsize=100",
              "--global.checknewversion=true",
              "--global.sendanonymoususage=true",
              "--entryPoints.traefik.address=:8080",
              "--entryPoints.web.address=:80",
              "--entryPoints.websecure.address=:443",
              "--entryPoints.postgres.address=:5432",
              #"--entryPoints.web.proxyProtocol.trustedIPs=127.0.0.1/32,172.31.0.0/16,192.168.0.0/16",
              #"--entryPoints.web.forwardedHeaders.trustedIPs=127.0.0.1/32,172.31.0.0/16,192.168.0.0/16",
              #"--entryPoints.websecure.proxyProtocol.trustedIPs=127.0.0.1/32,172.31.0.0/16,192.168.0.0/16",
              #"--entryPoints.websecure.forwardedHeaders.trustedIPs=127.0.0.1/32,172.31.0.0/16,192.168.0.0/16",
              "--entrypoints.web.http.redirections.entryPoint.to=websecure",
              "--entrypoints.web.http.redirections.entryPoint.scheme=https",
              "--ping=true",
              "--providers.kubernetescrd",
              "--log.level=INFO",
              "--providers.kubernetesingress=true",
              "--providers.kubernetesingress.ingressclass=traefik",
              "--certificatesresolvers.le.acme.email=info@myjourneysalud.com",
              "--certificatesResolvers.le.acme.dnsChallenge",
              "--certificatesResolvers.le.acme.dnsChallenge.provider=digitalocean",
              "--certificatesresolvers.le.acme.storage=/acme/acme.json",
              "--certificatesresolvers.le.acme.caserver=https://acme-v02.api.letsencrypt.org/directory",
              "--accesslog.fields.headers.names.User-Agent=redact",
              "--accesslog.fields.headers.names.Authorization=drop",
              "--accesslog.fields.headers.names.Content-Type=keep",
              "--metrics.prometheus=true",
              "--metrics.prometheus.buckets=0.1,0.3,1.2,5.0",
              #"--pilot.token=9f2bc994-d5a1-45fa-894e-a2b886133692"
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
          name = "config"
          config_map {
            name = "traefik-ingress-controller"
          }
        }

        volume {
          name = "acme"
          persistent_volume_claim {
            claim_name = "traefik-acme-disk"
          } 
        }
      }
    }
  }
}

resource "kubernetes_service" "traefik" {
  metadata {
    name = "traefik-ingress-service"
    annotations = {
        name = "ingress-control"
    }
    namespace = "ingress"
  }

  spec {
    selector = {
      App = kubernetes_deployment.traefik.spec.0.template.0.metadata[0].labels.App
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }

    port {
      name        = "admin"
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_manifest" "ingress-service" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRoute"
        metadata = {
            name = "traefik-dashboard"
            namespace = "ingress"
        }
        spec = {
            
            entryPoints = [ 
              "websecure"
            ]

            routes = [{
              kind = "Rule"
              match = "Host(`ingress.${var.domain}`)"
              
              services = [{
                kind = "TraefikService"
                name = "api@internal"
              }]

              middlewares = [{
                name = "basic-auth"
                namespace = "ingress"
              },
              {
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

resource "kubernetes_secret" "traefik-basic-auth-credential" {
  metadata {
    name = "traefik-basic-auth"
    namespace = "ingress"
  }

  data = {
    auth = "devops:$apr1$75flgnQt$at5kv/fCYow/jx5unElBm."
  }

  #type = "kubernetes.io/basic-auth"
}

resource "kubernetes_manifest" "middleware-https-redirect" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "Middleware"
        metadata = {
            name = "redirect-https"
            namespace = "ingress"
        }
        spec = {
            redirectScheme = {
              scheme = "https",
              permanent = true
              port = "443"
            }
        }
    }
}

resource "kubernetes_manifest" "middleware-auth" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "Middleware"
        metadata = {
            name = "basic-auth"
            namespace = "ingress"
        }
        spec = {
            basicAuth = {
              secret = "traefik-basic-auth"
            }
        }
    }
}

resource "digitalocean_record" "ingress-record" {
  domain = var.domain
  type   = "A"
  name   = "ingress"
  value  = data.digitalocean_loadbalancer.myjourney.ip
}

resource "digitalocean_record" "wildcard" {
  domain = var.domain
  type   = "A"
  name   = "*"
  value  = data.digitalocean_loadbalancer.myjourney.ip
}