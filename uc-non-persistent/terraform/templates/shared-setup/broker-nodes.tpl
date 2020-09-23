
{
  "broker_nodes":
  ${jsonencode(
    [
      for node in nodes: {
        "type": "vm_node",
        "name": "${node.name}",
        "size": "${node.size}",
        "public_ip": "${node.public_ip_address}",
        "private_ip": "${node.private_ip_address}",
        "admin_username": "${node.admin_username}"
      }
    ]
    )}
}
