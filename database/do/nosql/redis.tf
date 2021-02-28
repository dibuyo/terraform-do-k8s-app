resource "kubernetes_config_map" "redis_config" {
  metadata {
    name = "redis-config"
    namespace = "datastore"
  }

  data = {
    "config.yaml" = file("./${path.module}/files/redis_config.yaml")
  }
}

resource "kubernetes_deployment" "redis" {

  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
    namespace = "datastore"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    strategy {
        type = "Recreate"
    }

    template {

      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {

        init_container {
            image = "busybox"
            name  = "init"

            command = [ "sh", "-c", "echo never >/host-sys/kernel/mm/transparent_hugepage/enabled" ]

            volume_mount {
                mount_path = "/host-sys"
                name = "host-sys"
            }
        }

        container {
          image = "redis:6.0"
          name  = "redis"

          command = [ "redis-server", "/redis-master/redis.conf" ]

          port {
            name = "redis"
            container_port = 6379
          }

          volume_mount {
            mount_path = "/redis-master-data"
            name = "data"
          }

          volume_mount {
            mount_path = "/redis-master/redis.conf"
            name = "config"
            sub_path = "config.yaml"
          }

          env {
            name = "MASTER"
            value = "true"
          }

          //args = ["--ignore-db-dir=lost+found"]

          resources {
            limits {
              cpu    = "0.1"
            }
          }

        }

        volume {
          name = "host-sys"
          host_path {
            path = "/sys"
          }
        }

        volume {
          name = "data"
          empty_dir {
          }
        }

        volume {
          name = "config"
          config_map {
            name = "redis-config"
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
    annotations = {
        name = "redis-service"
    }
    namespace = "datastore"
  }

  spec {
    selector = {
      app = kubernetes_deployment.redis.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "redis"
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}