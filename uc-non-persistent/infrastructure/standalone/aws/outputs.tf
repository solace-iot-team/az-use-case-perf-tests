output "sdkperf-node-public-ips" {
  value = ["${aws_instance.sdkperf-nodes.*.public_ip}"]
}
output "sdkperf-node-private-ips" {
  value = ["${aws_instance.sdkperf-nodes.*.private_ip}"]
}

output "solace-broker-node-public-ips" {
  value = ["${aws_instance.solace-broker-nodes.*.public_ip}"]
}
output "solace-broker-node-private-ips" {
  value = ["${aws_instance.solace-broker-nodes.*.private_ip}"]
}
output "solace-broker-console" {
  value = ["http://${aws_instance.solace-broker-nodes[0].public_ip}:8080 - admin/admin"]
}
