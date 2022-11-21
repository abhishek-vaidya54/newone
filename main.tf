data "google_secret_manager_secret_version" "secret1" {




 secret = "awsvpnsharedkey1"


 project = "sat-host-nonprod"


}

data "google_secret_manager_secret_version" "secret2" {


 secret = "awsvpnsharedkey2"


 project = "sat-host-nonprod"


}







data "google_secret_manager_secret_version" "secret3" {


 secret = "awsvpnsharedkey3"


 project = "sat-host-nonprod"


}












data "google_secret_manager_secret_version" "secret4" {


 secret = "awsvpnsharedkey4"


 project = "sat-host-nonprod"


}












resource "google_compute_router" "cloud_router_vpn" {


 name    = "sat-host-qa-vpn-router"


 network = "sat-dev-vpc"


 project = "sat-host-nonprod"


 region  = "us-east4"


 bgp {


   asn               = 64513


   advertise_mode    = "DEFAULT"



   }


}







resource "google_compute_ha_vpn_gateway" "target_gateway" {


 provider = "google"


 name     = "aws-gcp-gateway"


 project = "sat-host-nonprod"


 region  = "us-east4"


 network  = "sat-dev-vpc"


}







resource "google_compute_external_vpn_gateway" "aws_gateway_qa" {


 provider        = "google"


 name            = "sat-aws-gateway-qa"


 project = "sat-host-nonprod"


 redundancy_type = "FOUR_IPS_REDUNDANCY"


 description     = "VPN gateway on AWS side"


interface {


   id         = 0


   ip_address = "54.156.221.235"


 }


interface {


   id         = 1


   ip_address = "54.235.13.116"


 }


interface {


   id         = 2


   ip_address = "34.202.171.46"


 }


interface {


   id         = 3


   ip_address = "52.72.232.216"


 }


}












resource "google_compute_vpn_tunnel" "tunnel1" {


 provider                        = "google"


 name                            = "sat-vpn-tunnel-1"


 project                         = "sat-host-nonprod"


 region                          = "us-east4"


 vpn_gateway                     = google_compute_ha_vpn_gateway.target_gateway.self_link


 shared_secret                   = data.google_secret_manager_secret_version.secret1.secret_data


 peer_external_gateway           = google_compute_external_vpn_gateway.aws_gateway_qa.self_link


 peer_external_gateway_interface = 0


 router                          = google_compute_router.cloud_router_vpn.name


 ike_version                     = 2


 vpn_gateway_interface           = 0


}







resource "google_compute_vpn_tunnel" "tunnel2" {


 provider                        = "google"


 project                         = "sat-host-nonprod"


 region                          = "us-east4"


 name                            = "sat-vpn-tunnel-2"


 vpn_gateway                     = google_compute_ha_vpn_gateway.target_gateway.self_link


 shared_secret                   = data.google_secret_manager_secret_version.secret2.secret_data


 peer_external_gateway           = google_compute_external_vpn_gateway.aws_gateway_qa.self_link


 peer_external_gateway_interface = 1


 router                          = google_compute_router.cloud_router_vpn.name


 ike_version                     = 2


 vpn_gateway_interface           = 0


}







resource "google_compute_vpn_tunnel" "tunnel3" {


 provider                        = "google"


 project                         = "sat-host-nonprod"


 region                          = "us-east4"


 name                            = "sat-vpn-tunnel-3"


 vpn_gateway                     = google_compute_ha_vpn_gateway.target_gateway.self_link


 shared_secret                   = data.google_secret_manager_secret_version.secret3.secret_data


 peer_external_gateway           = google_compute_external_vpn_gateway.aws_gateway_qa.self_link


 peer_external_gateway_interface = 2


 router                          = google_compute_router.cloud_router_vpn.name


 ike_version                     = 2


 vpn_gateway_interface           = 1


}







resource "google_compute_vpn_tunnel" "tunnel4" {


 provider                        = "google"


 project                         = "sat-host-nonprod"


 region                          = "us-east4"


 name                            = "sat-vpn-tunnel-4"


 vpn_gateway                     = google_compute_ha_vpn_gateway.target_gateway.self_link


 shared_secret                   = data.google_secret_manager_secret_version.secret4.secret_data


 peer_external_gateway           = google_compute_external_vpn_gateway.aws_gateway_qa.self_link


 peer_external_gateway_interface = 3


 router                          = google_compute_router.cloud_router_vpn.name


 ike_version                     = 2


 vpn_gateway_interface           = 1


}







resource "google_compute_router_interface" "interface-qa-main-1" {


 name       = "sat-qa-interface-1"


 project    = "sat-host-nonprod"


 region     = "us-east4"


 router     = google_compute_router.cloud_router_vpn.name


 ip_range   = "169.254.76.222/30"


 vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name


}







resource "google_compute_router_interface" "interface-qa-main-2" {


 name       = "sat-qa-interface-2"


 project    = "sat-host-nonprod"


 region     = "us-east4"


 router     = google_compute_router.cloud_router_vpn.name


 ip_range   = "169.254.121.234/30"


 vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name


}







resource "google_compute_router_interface" "interface-qa-main-3" {


 name       = "sat-qa-interface-3"


 project    = "sat-host-nonprod"


 region     = "us-east4" 


 router     = google_compute_router.cloud_router_vpn.name


 ip_range   = "169.254.227.198/30"


 vpn_tunnel = google_compute_vpn_tunnel.tunnel3.name


}







resource "google_compute_router_interface" "interface-qa-main-4" {


 name       = "sat-qa-interface-4"


 project    = "sat-host-nonprod"


 region     = "us-east4" 


 router     = google_compute_router.cloud_router_vpn.name


 ip_range   = "169.254.98.234/30"


 vpn_tunnel = google_compute_vpn_tunnel.tunnel4.name


}












resource "google_compute_router_peer" "qa-main-1" {


 name                      = "sat-qa-peer-1"


 project                   = "sat-host-nonprod"


 region                    = "us-east4" 


 router                    = google_compute_router.cloud_router_vpn.name


 peer_ip_address           = "169.254.76.221"


 peer_asn                  = 65533


 advertised_route_priority = 100


 interface                 = google_compute_router_interface.interface-qa-main-1.name


}












resource "google_compute_router_peer" "qapeer-main-2" {


 name                      = "sat-qa-peer-2"


 project                   = "sat-host-nonprod"


 region                    = "us-east4" 


 router                    = google_compute_router.cloud_router_vpn.name


 peer_ip_address           = "169.254.121.233"


 peer_asn                  = 65533


 advertised_route_priority = 100


 interface                 = google_compute_router_interface.interface-qa-main-2.name


}







resource "google_compute_router_peer" "qapeer-main-3" {


 name                      = "sat-qa-peer-3"


 project                   = "sat-host-nonprod"


 region                    = "us-east4" 


 router                    = google_compute_router.cloud_router_vpn.name


 peer_ip_address           = "169.254.227.197"


 peer_asn                  = 65533


 advertised_route_priority = 100


 interface                 = google_compute_router_interface.interface-qa-main-3.name


}







resource "google_compute_router_peer" "qapeer-main-4" {


 name                      = "sat-qa-peer-4"


 project                   = "sat-host-nonprod"


 region                    = "us-east4" 


 router                    = google_compute_router.cloud_router_vpn.name


 peer_ip_address           = "169.254.98.233"


 peer_asn                  = 65533


 advertised_route_priority = 100


 interface                 = google_compute_router_interface.interface-qa-main-4.name


}

