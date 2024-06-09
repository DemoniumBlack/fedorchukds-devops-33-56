output "all_vms" {
  value = flatten([
    [for i in yandex_compute_instance.master : {
      name = i.name
      ip_external   = i.network_interface[0].nat_ip_address
      ip_internal = i.network_interface[0].ip_address
    }],
    [for i in yandex_compute_instance.worker : {
      name = i.name
      ip_external   = i.network_interface[0].nat_ip_address
      ip_internal = i.network_interface[0].ip_address
    }]
  ])
}

output "Grafana_Network_Load_Balancer_Address" {
  value = yandex_lb_network_load_balancer.nlb-grafana.listener.*.external_address_spec[0].*.address
  description = "Адрес сетевого балансировщика для Grafana"
}

output "Web_App_Network_Load_Balancer_Address" {
  value = yandex_lb_network_load_balancer.nlb-web-app.listener.*.external_address_spec[0].*.address
  description = "Адрес сетевого балансировщика Web App"
}