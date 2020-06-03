# F5 and Terraform Demo Deployment

Terraform BIG-IP Provider [documentation](https://www.terraform.io/docs/providers/bigip/index.html)

## Terraform instalation


## BIG-IP Preparation

1. Console
  * Login as root, set the password
  * `# config` -> set the static IP and Default GW
  * `# tmsh modify sys global-settings mgmt-dhcp disabled`
  * `# tmsh save sys config`
2. WebUI
  * Login as admin, set the new password (or `# tmsh modify auth user admin password <password>`)
  * License the box (as TF can't license F5, only via BIG-IQ License Manager)

## Examples

```shell
$ cd ./example1
$ terraform init # initialize the config and download providers
$ terraform plan # build the plan
$ terraform apply # apply the configuration
```

### ./example1

* basic example with variables included directly in the config, please validate the provider configuration before use
* BIG-IP Configuration includes networking, DNS, NTP, VS and Pool

### ./example2

* pretty much the same example as the ./example1, the difference is usage of iApp defined as JSON to configure the VS, Pool and whole App configuration

### ./example3

* an [./example1](https://github.com/erkac/f5-terraform#example1) based demo
* variables stored in .tfvars file
  * please fill the correct credentials and options into _terraform.tfvars_
* besides the BIG-IP, TF will also create a DNS record in Cloudflare
* as example of linking values for the Cloudflare DNS A Record is used the _bigip_ltm_virtual_server.http.destination_ value

## Terraform Notes

### Remove Virtual Server Configuration
```shell
$ terraform destroy -target=bigip_ltm_virtual_server.http
```

### Remove Pool attachment configuration
```shell
$ terraform destroy -target=bigip_ltm_pool_attachment.attach_node
```

### Remove Pool Configuration
```shell
$ terraform destroy -target=bigip_ltm_pool.pool
```

### Remove All remaining Configuration
```shell
$ terraform destroy
```


