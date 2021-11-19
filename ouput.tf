output "domain"{
    value = var.domain
    description = "Nombre del dominio configurado."
}

output "random_name"{
    value = random_string.domain.result
    description = "Contraseña de la base de datos MYSQL"
    sensitive   = true
}

output "lb_output" {
    description = "Dirección IP Load Balancer"
    value = data.digitalocean_loadbalancer.myjourney.ip
}

/*output "metabase_pwd" {
    description = "Metabase Password MYSQL"
    value = random_password.metabase_pwd.result
}*/

output "user_name" {
  value       = module.storage.user_name
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = module.storage.user_arn
  description = "The ARN assigned by AWS for this user"
}

output "access_key_id" {
  value       = module.storage.access_key_id
  description = "The access key ID"
}

/*output "secret_access_key" {
  value       = module.storage.secret_access_key
  description = "The secret access key. This will be written to the state file in plain-text"
}*/

output "k8s_endpoint" {
  value       = module.k8s.k8s_endpoint
  description = "Endpoint K8s Digital Ocean"
}

output "templates" {
  value = data.http.sendgrid_templates.body
}

#output "web_ipv4_address" {
#  description = "List of IPv4 addresses of web Droplets"
#  value       = module.web.ipv4_address
#}