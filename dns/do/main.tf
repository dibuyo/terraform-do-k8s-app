locals {
  default_ttl = 3600
  mx_records = {
    "aspmx.l.google.com." = 1
    "alt1.aspmx.l.google.com." = 5
    "alt2.aspmx.l.google.com." = 5
    "alt3.aspmx.l.google.com." = 10
    "alt4.aspmx.l.google.com." = 10
  }
  sendgrid_records = {
    "em8529" = "u20019805.wl056.sendgrid.net."
    "s1._domainkey" = "s1.domainkey.u20019805.wl056.sendgrid.net."
    "s2._domainkey" = "s2.domainkey.u20019805.wl056.sendgrid.net."
    "url1325" = "sendgrid.net."
    "20019805" = "sendgrid.net."
  }
}

resource "digitalocean_domain" "public_domain" {
  name       = var.domain
  ip_address = var.loadbalancer_ip
}

resource "digitalocean_domain" "public_domain_alt" {
  name       = var.domain_alt
  ip_address = var.loadbalancer_ip
}

resource "digitalocean_record" "public_apex" {
  domain = var.domain
  type   = "A"
  name   = "@"
  value  = var.loadbalancer_ip
}

resource "digitalocean_record" "public_apex_alt" {
  domain = var.domain_alt
  type   = "A"
  name   = "@"
  value  = var.loadbalancer_ip
}

resource "digitalocean_record" "mx_alt_records" {
  for_each = local.mx_records
  domain   = var.domain_alt
  type     = "MX"
  name     = "@"
  priority = each.value
  value    = each.key
  ttl      = local.default_ttl
}

resource "digitalocean_record" "postgresdb_record" {
  domain = var.domain
  type   = "A"
  name   = "postgresdb"
  value  = var.loadbalancer_ip
}

resource "digitalocean_record" "mx_records" {
  for_each = local.mx_records
  domain   = var.domain
  type     = "MX"
  name     = "@"
  priority = each.value
  value    = each.key
  ttl      = local.default_ttl
}

resource "digitalocean_record" "sengrid_records" {
  for_each = local.sendgrid_records
  domain   = var.domain
  type     = "CNAME"
  name     = each.key
  value    = each.value
}

resource "digitalocean_record" "mx_workspace_validate" {
  priority = 15
  domain = var.domain
  type   = "MX"
  name   = "@"
  value  = "yiw6o7s6apl752b3cv6oau6iagsm6heu6y3lyr6djx3k46sjnn3a.mx-verification.google.com."
}

resource "digitalocean_record" "wildcard_alt" {
  domain = var.domain_alt
  type   = "A"
  name   = "*"
  value  = var.loadbalancer_ip
}

resource "digitalocean_record" "www_domain_alt" {
  domain = var.domain_alt
  type   = "A"
  name   = "www"
  value  = var.loadbalancer_ip
}
/*
resource "digitalocean_record" "sendgrid_cname_01" {
  domain = var.domain
  type   = "CNAME"
  name   = "em8751"
  #name   = format("em8751.%s", var.domain)
  value  = "u20019805.wl056.sendgrid.net."
}

resource "digitalocean_record" "sendgrid_domainkey_01" {
  domain = var.domain
  type   = "CNAME"
  name   = "s1._domainkey"
  value  = "s1.domainkey.u20019805.wl056.sendgrid.net."
}

resource "digitalocean_record" "sendgrid_domainkey_02" {
  domain = var.domain
  type   = "CNAME"
  name   = "s2._domainkey"
  value  = "s2.domainkey.u20019805.wl056.sendgrid.net."
}

resource "digitalocean_record" "sendgrid_cname_02" {
  domain = var.domain
  type   = "CNAME"
  name   = "url2736"
  value  = "sendgrid.net."
}

resource "digitalocean_record" "sendgrid_cname_03" {
  domain = var.domain
  type   = "CNAME"
  name   = "20019805"
  value  = "sendgrid.net."
}
*/