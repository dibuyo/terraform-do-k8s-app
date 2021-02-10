resource "random_password" "metabase_pwd" {
  length = 16
  special = true
  override_special = "_%@"
}

module "storage" {
  source = "./storage/aws"
}

module "dns" {
  source = "./dns/do"

  domain = var.domain
  domain_alt = var.domain_alt
  loadbalancer_ip = data.digitalocean_loadbalancer.myjourney.ip
}

module "k8s" {
  source = "./k8s/do"

  node_count = var.node_count
}

module "nosql" {
  source = "./database/do/nosql"

  namespace = "datastore"
  name = "myjourney"
  storage_size = "10Gi"
  replicacount = 1
}

module "datastore" {
  source = "./database/do/sql"

  domain = var.domain

  mysql_root_pwd = var.mysql_root_pwd
  mysql_default_database = var.mysql_default_database
  mysql_usr_wordpress = var.mysql_usr_wordpress
  mysql_pwd_wordpress = var.mysql_pwd_wordpress

  postgres_database = var.postgres_database
  postgres_user = var.postgres_user
  postgres_password = var.postgres_password
}

module "app" {
  source = "./app/do"

  domain = var.domain
  domain_alt = var.domain_alt

  mysql_instance_name = var.mysql_default_database
  mysql_usr_wordpress = var.mysql_usr_wordpress
  mysql_pwd_wordpress = var.mysql_pwd_wordpress
  mysql_usr_wordpress_alt = var.mysql_usr_wordpress_alt
  mysql_pwd_wordpress_alt = var.mysql_pwd_wordpress_alt
  mysql_namespace = module.datastore.datastore_namespace

  metabase_url = "${var.metabase_subdomian}.${var.domain}"
  metabase_db = var.metabase_db
  metabase_usr = var.metabase_usr_name
  metabase_pwd = var.metabase_pwd #random_password.metabase_pwd.result

  pgadmin_default_email = var.pgadmin_default_email
  pgadmin_default_password = var.pgadmin_default_password
}