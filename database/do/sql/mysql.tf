resource "kubernetes_config_map" "mysql_initdb_config" {
  metadata {
    name = "mysql-initdb-config"
    namespace = "datastore"
  }

  data = {
    "initdb.sql" = file("./${path.module}/run/mysql_initdb.sql")
    "wordpress.sql" = file("./${path.module}/run/wordpress.sql")
  }
}

resource "kubernetes_persistent_volume_claim" "mysql-volume-claim" {
  
  metadata {
    name = "mysql-pv-claim"
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

resource "kubernetes_deployment" "mysql" {

  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
    namespace = "datastore"
  }

  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    strategy {
        type = "Recreate"
    }

    template {

      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {

        /*container {
            image = "k8s.gcr.io/busybox"
            name  = "init"

            command = [ "/bin/sh","-c","ls -l /var/lib/mysql" ]

            volume_mount {
                mount_path = "/var/lib/mysql"
                name = "mysql-persistent-storage"
            }
        }*/

        container {
          image = "mysql:5.7"
          name  = "mysql"

          port {
            container_port = 3306
          }

          volume_mount {
            mount_path = "/var/lib/mysql"
            name = "mysql-persistent-storage"
          }

          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name = "mysql-initdb"
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_pwd
          }

          /*env {
              name = "MYSQL_DATABASE"
              value = var.mysql_default_database
          }

          env{
            name = "MYSQL_USER"
            value = var.mysql_usr_wordpress
          }

          env{
            name= "MYSQL_PASSWORD"
            value = var.mysql_pwd_wordpress
          }*/

          args = ["--ignore-db-dir=lost+found"]

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
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = "mysql-pv-claim"
          } 
        }

        volume {
          name = "mysql-initdb"
          config_map {
            name = "mysql-initdb-config"
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
    annotations = {
        name = "mysql-service"
    }
    namespace = "datastore"
  }

  spec {
    selector = {
      app = kubernetes_deployment.mysql.spec.0.template.0.metadata[0].labels.app
    }
    
    port {
      name        = "database"
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
    #type = "LoadBalancer"
  }
}