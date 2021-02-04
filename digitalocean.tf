provider "random" {}

provider "digitalocean" {
  token = var.do_token
}

resource "random_string" "domain" {
  length  = 10
  special = false
  upper   = false
}

data "digitalocean_loadbalancer" "myjourney" {
  name = var.do_load_balancer_name
}

#data "digitalocean_domain" "public_domain" {
#  name = var.domain
#}

#output "domain_output" {
#  value = data.digitalocean_domain.myjourneysalud.zone_file
#}