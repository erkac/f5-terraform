provider "bigip" {
   address = "10.1.1.245"
   username = "admin"
   password = "admin"
}

resource "bigip_sys_provision" "provision-ltm" {
 name         = "ltm"
 full_path    = "ltm"
 cpu_ratio    = 0
 disk_ratio   = 0
 level        = "nominal"
 memory_ratio = 0
}

# resource "bigip_cm_device" "my_new_device" {
#  name                = "bigipA.f5demo.app"
#  configsync_ip       = "10.1.1.245"
# }

resource "bigip_sys_ntp" "ntp1" {
    description = "/Common/NTP1"
    servers = ["time.google.com"]
    timezone = "Europe/Bratislava"
}

resource "bigip_sys_dns" "dns1" {
    description = "/Common/DNS1"
    name_servers = ["8.8.8.8"]
    number_of_dots = 2
    search = ["f5.com"]
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
        timeout = "16"
        interval = "5"
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
        pool = "/Common/terraform-pool"
        name = "/Common/terraform_vs_http"
        destination = "10.1.10.100"
        port = 80
        source_address_translation = "automap"
        depends_on = [bigip_ltm_pool.pool]
}
