{
    "latency_nodes":
    ${jsonencode(
      [
        for node in latency_nodes: {
          "cloud_provider": "azure",
          "location": "${node.location}",
          "name": "${node.name}",
          "size": "${node.size}",
          "public_ip": "${node.public_ip_address}",
          "private_ip": "${node.private_ip_address}",
          "admin_username": "${node.admin_username}",
          "node_details": "${node}"
        }
      ]
      )}
      ,
      "publisher_nodes":
      ${jsonencode(
        [
          for node in publisher_nodes: {
            "cloud_provider": "azure",
            "location": "${node.location}",
            "name": "${node.name}",
            "size": "${node.size}",
            "public_ip": "${node.public_ip_address}",
            "private_ip": "${node.private_ip_address}",
            "admin_username": "${node.admin_username}",
            "node_details": "${node}"
          }
        ]
        )}
    ,
    "consumer_nodes":
    ${jsonencode(
      [
        for node in consumer_nodes: {
          "cloud_provider": "azure",
          "location": "${node.location}",
          "name": "${node.name}",
          "size": "${node.size}",
          "public_ip": "${node.public_ip_address}",
          "private_ip": "${node.private_ip_address}",
          "admin_username": "${node.admin_username}",
          "node_details": "${node}"
        }
      ]
      )}


}
