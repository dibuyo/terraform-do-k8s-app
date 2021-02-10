variable "domain" {
    type = string
}

variable "domain_alt" {
    type = string
}

variable "mysql_usr_wordpress" {
    type = string
}

variable "mysql_pwd_wordpress" {
    type = string
}

variable "mysql_pwd_wordpress_alt" {
    type = string
}

variable "mysql_usr_wordpress_alt" {
    type = string
}

variable "mysql_instance_name" {
    type = string
}

variable "mysql_namespace" {
    type = string
}

variable "metabase_usr"{
    type = string
}

variable "metabase_pwd"{
    type = string
}

variable "metabase_url"{
    type = string
}

variable "metabase_db"{
    type = string
}

variable "pgadmin_default_email" {
    type = string
    default = "myjourneydb"
}

variable "pgadmin_default_password" {
    type = string
}