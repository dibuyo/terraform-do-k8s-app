## Terraform

- Website: https://www.terraform.io
- Forums: [HashiCorp Discuss](https://discuss.hashicorp.com/c/terraform-core)
- Documentation: [https://www.terraform.io/docs/](https://www.terraform.io/docs/)

## Terraform versions

Version used:
*   Terraform 0.14

## Cloud
* Digital Ocean
* AWS

## Services
* AWS
* * S3
* Digital Ocen
* * DNS Domain + MX Workspace + SendGrid Check
* * K8s ( Nodes 4 + Size s-2vcpu-4gb )
* * MySQL
* * Postgre
* * MongoDB
* * Metabase
* * Verdaccio
* * Wordpress

## Variables
* do_token: Token Digital Ocean
* domain: Main Domain Name
* aws_access_key: AWS Access Key
* aws_secret_key: AWS Secret Key

## Getting Started

Before terraform apply you must download provider plugin:

```
terraform init
```

Display plan before apply manifest
```
terraform plan
```

Apply manifest
```
terraform apply
```

Destroy stack
```
terraform destroy
```

## Documentation

[https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs]

[https://registry.terraform.io/providers/hashicorp/kubernetes-alpha/latest]

[https://registry.terraform.io/providers/hashicorp/kubernetes/latest]

[https://www.terraform.io/docs/providers/aws/](https://www.terraform.io/docs/providers/aws/)

[https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples)
