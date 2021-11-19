resource "kubernetes_config_map" "postgres_initdb_config" {
  metadata {
    name = "postgres-initdb-config"
    namespace = "datastore"
  }

  data = {
    "initdb.sql" = file("./${path.module}/run/postgres_initdb.sql")
  }
}

resource "kubernetes_config_map" "postgres_conf_files" {
  metadata {
    name = "postgres-config-files"
    namespace = "datastore"
  }

  data = {
    "postgresql.conf" = file("./${path.module}/run/postgresql.conf")
    "pg_hba.conf" = file("./${path.module}/run/pg_hba.conf")
  }
}

resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name = "postgres-config"
    namespace = "datastore"
  }

  data = {
    "POSTGRES_DB" = "myjoruneydb"
    "POSTGRES_USER" = var.postgres_user
    "POSTGRES_PASSWORD" = var.postgres_password
    "PGDATA" = "/var/lib/postgresql/data/databases"
  }
}

resource "kubernetes_persistent_volume_claim" "postgres-volume-claim" {
  
  metadata {
    name = "postgres-pv-claim"
    namespace = "datastore"
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "10Gi"
      }
    }

    #volume_name = "${kubernetes_persistent_volume.example.metadata.0.name}"
  }
}

resource "kubernetes_deployment" "postgres" {

  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
    namespace = "datastore"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    strategy {
        type = "Recreate"
    }

    template {

      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {

        container {
          image = "postgres:13.5"
          name  = "postgres"

          port {
            container_port = 5432
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name = "postgres-persistent-storage"
          }

          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name = "postgres-initdb"
          }

          volume_mount {
            mount_path = "/etc/postgresql"
            name = "config-files"
          }

          env_from {
            config_map_ref {
                name = kubernetes_config_map.postgres_config.metadata[0].name
            }
          }

          args = []

          /*resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }*/

        }

        volume {
          name = "postgres-persistent-storage"
          persistent_volume_claim {
            claim_name = "postgres-pv-claim"
          } 
        }

        volume {
          name = "postgres-initdb"
          config_map {
            name = kubernetes_config_map.postgres_initdb_config.metadata[0].name
          }
        }

        volume {
          name = "config-files"
          config_map {
            name = kubernetes_config_map.postgres_conf_files.metadata[0].name
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    annotations = {
        name = "postgres-service"
    }
    namespace = "datastore"
  }

  spec {
    selector = {
      app = kubernetes_deployment.postgres.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "database"
      port        = 5432
      target_port = 5432
    }

    #type = "NodePort"
    type = "ClusterIP"
    #type = "LoadBalancer"
  }
}
/*
resource "kubernetes_manifest" "postgres_ingress_route" {
    provider = kubernetes-alpha
  
    manifest =  {
        apiVersion = "traefik.containo.us/v1alpha1"
        kind = "IngressRouteTCP"
        metadata = {
            name = "postgres"
            namespace = "datastore"
        }
        spec = {
            
            entryPoints = [ 
              "postgres"
            ]

            routes = [{
              kind = "Rule"
              match = "HostSNI(`*`)"
              //match = "HostSNI(`postgresdb.${var.domain}`)"
              
              services = [{
                name = "postgres"
                port = 5432
              }]
            }]

            //tls = {
            //  certResolver = "le"
            //  domains = [{
            //    main = "postgresdb.${var.domain}"
            //  }]
            //}
        }
    }
}
*/