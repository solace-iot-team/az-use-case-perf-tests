{
  "sdkperf_nodes":
  ${jsonencode(
    [
      for node in nodes: {
        "cloud_provider": "aws",
        "location": "TODO", #TODO
        "name": "${node.host_id}",
        "size": "TODO", #TODO
        "public_ip": "${node.public_ip}",
        "private_ip": "${node.private_ip}",
        "admin_username": "centos",
        "node_details": "${node}"
      }
    ]
    )}
}
