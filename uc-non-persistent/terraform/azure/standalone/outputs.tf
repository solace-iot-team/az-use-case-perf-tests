output "sdkperf-node-public-ips" {
  value = ["${azurerm_linux_virtual_machine.sdkperf-nodes.*.public_ip_address}"]
}

output "sdkperf-node-private-ips" {
  value = ["${azurerm_linux_virtual_machine.sdkperf-nodes.*.private_ip_address}"]
}

output "solace-broker-node-public-ips" {
  value = ["${azurerm_linux_virtual_machine.solace-broker-nodes.*.public_ip_address}"]
}
output "solace-broker-node-private-ips" {
  value = ["${azurerm_linux_virtual_machine.solace-broker-nodes.*.private_ip_address}"]
}
