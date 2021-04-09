resource "kubernetes_deployment" "myjourney_scheduler" {

  metadata {
    name = "myjourney-scheduler"
    labels = {
      app = "myjourney-scheduler"
    }
    namespace = "app"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "myjourney-scheduler"
      }
    }

    template {

      metadata {
        labels = {
          app = "myjourney-scheduler"
        }
      }

      spec {

        container {
          image_pull_policy = "Always"
          image = "registry.digitalocean.com/myjourney-apps/scheduler:test"
          name  = "myjourney-scheduler"

          volume_mount {
              mount_path = "/usr/src/scheduler/.env"
              sub_path = ".env"
              name = "myjourney-scheduler-config-path"
              read_only = true
          }

          /*env {
            name = "REDIS_HOST"
            value = "redis.datastore.svc.cluster.local."
          }*/
          env {
            name = "SENTRY_DSN"
            value = "https://8b5f8f3c1db144f8ac070940138ea0db@o564212.ingest.sentry.io/5706743"
          }

          port {
            container_port = 3000
          }
        }

        volume {
            name = "myjourney-scheduler-config-path"
            config_map {
                name = "myjourney-api-config"
            }
        }
      }
    }
  }
}

resource "kubernetes_service" "myjourney-scheduler" {
  metadata {
    name = "myjourney-scheduler"
    annotations = {
        name = "myjourney-scheduler"
    }
    namespace = "app"
  }

  spec {
    selector = {
      app = kubernetes_deployment.myjourney_scheduler.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
    
    type = "ClusterIP"
  }
}