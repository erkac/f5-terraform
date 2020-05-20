# F5 Networks and Terraform Demo Deployment

Terraform BIG-IP Provider [documentation](https://www.terraform.io/docs/providers/bigip/index.html)

## BIG-IP Preparation

1. Console
  * Login as root, set the password
  * `# config` -> set the static IP and Default GW
2. WebUI
  * Login as admin, set the new password (or `# tmsh modify auth user admin password <password>`)
  * License the box

## Examples

### ./example1

### ./example2

### ./example3

## Terraform Notes

### Remove Virtual Server Configuration
        $ terraform destroy -target=bigip_ltm_virtual_server.http

### Remove Pool attachment configuration

        $ terraform destroy -target=bigip_ltm_pool_attachment.attach_node

### Remove Pool Configuration

        $ terraform destroy -target=bigip_ltm_pool.pool

### Remove All remaining Configuration

        $ terraform destroy

terraform plan

