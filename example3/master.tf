
variable "bigip-mgmt" {}
variable "bigip-user" {}
variable "bigip-passwd" {}

variable "cloudflare_email" {}
variable "cloudflare_token" {}

variable "base_domain" {}
variable "appname" {}
variable "vip" {}


provider "bigip" {
   address = var.bigip-mgmt
   username = var.bigip-user
   password = var.bigip-passwd
}

provider "cloudflare" {
  version = "~> 2.0"
  email = var.cloudflare_email
  api_key = var.cloudflare_token
}

resource "bigip_sys_ntp" "ntp1" {
    description = "/Common/NTP1"
    servers = ["time.google.com"]
    timezone = "Europe/Bratislava"
}

resource "bigip_sys_dns" "dns1" {
    description = "/Common/DNS1"
    name_servers = ["8.8.8.8"]
    number_of_dots = 2
    search = ["f5demo.app"]
}

resource "bigip_net_vlan" "vlan1" {
    name = "/Common/internal"
    tag = 101
    interfaces {
        vlanport = 1.2
        tagged = false
    }
}

resource "bigip_net_vlan" "vlan2" {
    name = "/Common/external"
    tag = 102
    interfaces {
        vlanport = 1.1
        tagged = false
    }
}

resource "bigip_net_selfip" "selfip1" {
    name = "/Common/internalselfIP"
    ip = "10.1.20.246/24"
    vlan = "/Common/internal"
    depends_on = [bigip_net_vlan.vlan1]
}

resource "bigip_net_selfip" "selfip2" {
    name = "/Common/externalselfIP"
    ip = "10.1.10.246/24"
    vlan = "/Common/external"
    depends_on = [bigip_net_vlan.vlan2]
}

resource "bigip_ltm_monitor" "monitor" {
        name = "/Common/terraform_monitor"
        parent = "/Common/http"
        send = "GET /\r\n"
        timeout = "999"
        interval = "999"
}

resource "bigip_ltm_pool"  "pool" {
        name = "/Common/terraform-pool"
        load_balancing_mode = "round-robin"
        monitors = ["/Common/terraform_monitor"]
        allow_snat = "yes"
        allow_nat = "yes"
}

resource "bigip_ltm_node" "node" {
  name             = "/Common/terraform_node1"
  address          = "10.1.20.17"
  connection_limit = "0"
  dynamic_ratio    = "1"
  monitor          = "/Common/icmp"
  description      = "Test-Node"
  rate_limit       = "disabled"
  fqdn {
    address_family = "ipv4"
    interval       = "3000"
  }
}

resource "bigip_ltm_pool_attachment" "attach_node" {
        pool = "/Common/terraform-pool"
        node = "${bigip_ltm_node.node.name}:80"
        depends_on = [bigip_ltm_pool.pool]
}

resource "bigip_ltm_virtual_server" "http" {
        name = "/Common/terraform_vs_http"
        description = "TF VirtualServer"
        destination = var.vip
        port = 8080
        #profiles = ["/Common/tcp", "/Common/http"]
        source_address_translation = "automap"
        pool = "/Common/terraform-pool"
        depends_on = [bigip_ltm_pool.pool]
}

resource "cloudflare_record" "f5demo" {
  zone_id = "9c465b6e5b0f29e8385311c55653c490"
  name    = var.appname
  value   = bigip_ltm_virtual_server.http.destination
  type    = "A"
  proxied = false
}

output "vip" {
  value = [ bigip_ltm_virtual_server.http.destination ]
  description = "F5 BIG-IP VS IP Address"
}