
{
  "broker_nodes":
  ${jsonencode(
    [
      for node in nodes: {
        "cloud_provider": "azure",
        "location": "${node.location}",
        "type": "vm_node",
        "name": "${node.name}",
        "size": "${node.size}",
        "public_ip": "${node.public_ip_address}",
        "private_ip": "${node.private_ip_address}",
        "admin_username": "${node.admin_username}",
        "accelerated_networking": "${enable_accelerated_networking}",
        "node_details": "${node}"
      }
    ]
    )}
}
