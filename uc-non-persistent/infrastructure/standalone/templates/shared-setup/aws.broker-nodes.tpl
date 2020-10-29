
{
  "broker_nodes":
  ${jsonencode(
    [
      for node in nodes: {
        "cloud_provider": "aws",
        "location": "TODO",
        "type": "vm_node",
        "name": "${node.host_id}",
        "size": "TODO",
        "public_ip": "${node.public_ip}",
        "private_ip": "${node.private_ip}",
        "admin_username": "centos",
        "node_details": "${node}"
      }
    ])}}
    