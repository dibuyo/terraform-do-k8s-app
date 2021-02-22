data "http" "sendgrid_templates" {
  url = "https://api.sendgrid.com/v3/templates"

  request_headers = {
    Content-Type = "application/json"
    Accept = "application/json"
    Authorization = "Bearer ${var.sg_apikey}"
  }
}