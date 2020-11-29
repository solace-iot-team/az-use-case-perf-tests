
{
  "all": {
    "vars": {
      "infrastructure": "${cloud_provider}.${tag_name_prefix}-standalone",
      "cloud_provider": "${cloud_provider}",
      "broker_pubsub": {
        "public_ip_address": "${broker_node.public_ip}",
        "private_ip_address": "${broker_node.private_ip}",
        "vpn_name": "sdkperf",
        "client_user_name": "testUsr",
        "client_user_name_pwd": "solace123"
      }
    },
    "hosts": {
      "broker_centos": {
        "ansible_host": "${broker_node.public_ip}",
        "ansible_user": "${admin_username}",
        "ansible_become": true,
        "ansible_python_interpreter": "/usr/bin/python",
        "boxname":"${broker_node.tags.Name}",
        "sdkperf_root": "/opt/sdkperf",
        "private_ip_address": "${broker_node.private_ip}"
      },
      "broker_pubsub": {
        "ansible_connection": "local",
        "sempv2_host": "${broker_node.public_ip}",
        "sempv2_port": 8080,
        "sempv2_is_secure_connection": false,
        "sempv2_username": "admin",
        "sempv2_password": "admin",
        "sempv2_timeout": "60",
        "virtual_router": "primary",
        "private_ip_address": "${broker_node.private_ip}"
      }
    }
  },

  "sdkperf_latency": {
    "hosts": {
        "${latency_node.tags.Name}": {
          "ansible_host": "${latency_node.public_ip}",
          "ansible_user": "${admin_username}",
          "ansible_python_interpreter": "/usr/bin/python",
          "boxname":"${latency_node.tags.Name}",
          "sdkperf_root": "/opt/sdkperf",
          "private_ip_address": "${latency_node.private_ip}"
        }
    }
  },

  "sdkperf_publishers": {
    "hosts": {

      %{ for node in publisher_nodes ~}

        "${node.tags.Name}": {
          "ansible_host": "${node.public_ip}",
          "ansible_user": "${admin_username}",
          "ansible_python_interpreter": "/usr/bin/python",
          "boxname":"${node.tags.Name}",
          "sdkperf_root": "/opt/sdkperf",
          "private_ip_address": "${node.private_ip}"
        },

      %{ endfor ~}

      "NOT_A_HOST":{
        "ansible_connection": "local"
      }

    }
  },

  "sdkperf_consumers": {
    "num_consumer_nodes": ${length(consumer_nodes)},
    "hosts": {

      %{ for node in consumer_nodes ~}

        "${node.tags.Name}": {
          "ansible_host": "${node.public_ip}",
          "ansible_user": "${admin_username}",
          "ansible_python_interpreter": "/usr/bin/python",
          "boxname":"${node.tags.Name}",
          "sdkperf_root": "/opt/sdkperf",
          "consumer_node_number": "${node.tags.consumer_node_number}",
          "private_ip_address": "${node.private_ip}"
        },

      %{ endfor ~}

      "NOT_A_HOST":{
        "ansible_connection": "local"
      }

    }
  }

}
