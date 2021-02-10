variable "domain" {
    type = string
    default = "myjourneysalud.com"
}

variable "domain_alt" {
    type = string
}

variable "do_token" {
    type = string
}

variable "do_load_balancer_name" {}

variable "auth_login" {}

variable "auth_password" {} 

# ------ Module database ------#
variable "mysql_root_pwd" {
    type = string
}

variable "mysql_default_database" {
    type = string
}

variable "mysql_usr_wordpress" {
    type = string
}

variable "mysql_pwd_wordpress" {
    type = string
}

variable "mysql_usr_wordpress_alt" {
    type = string
}

variable "mysql_pwd_wordpress_alt" {
    type = string
}

variable "metabase_usr_name"{
    type = string
    default = "usr_metabase_db"
}

variable "metabase_pwd"{
    type = string
}

variable "metabase_db"{
    type = string
}

# ------ Module sendgird ------#
variable "sg_apikey" {
    type = string
}

# ------ Metabase ------- #
variable "metabase_subdomian"{
    type = string
    default = "reportes"
}

# ------ AWS ------ #
variable "aws_access_key" {
    type = string
}

variable "aws_secret_key" {
    type = string
}

# ------ K8s ------ #
variable "node_count" {
    type = number
    default = 4
    description = "Cantidad de Nodos Workers para K8s"
}

# ------ Postgre ------ #
variable "postgres_database" {
    type = string
    default = "myjourneydb"
}

variable "postgres_user" {
    type = string
}

variable "postgres_password" {
    type = string
}

# ------ PgAdmin ------ #
variable "pgadmin_default_email" {
    type = string
    default = "myjourneydb"
}

variable "pgadmin_default_password" {
    type = string
}