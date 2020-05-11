# f5-terraform
F5 Networks demo using Terraform


## Examples


### Remove Virtual Server Configuration
        $ terraform destroy -target=bigip_ltm_virtual_server.http

### Remove Pool attachment configuration

        $ terraform destroy -target=bigip_ltm_pool_attachment.attach_node

### Remove Pool Configuration

        $ terraform destroy -target=bigip_ltm_pool.pool

### Remove All remaining Configuration

        $ terraform destroy


### 1. Modify the master.tf file to configure the iApp resource to use simple http JSON file
```
resource "bigip_sys_iapp" "simplehttp" {
        name = "simplehttp"
        jsonfile = "${file("simplehttp.json")}"
}
```

terraform plan

