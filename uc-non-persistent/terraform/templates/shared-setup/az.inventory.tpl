
{
  "all": {
    "vars": {
      "infrastructure": "${cloud_provider}.${tag_name_prefix}-standalone",
      "cloud_provider": "${cloud_provider}",
      "broker_pubsub": {
        "public_ip_address": "${solace_broker_nodes[0].public_ip_address}",
        "private_ip_address": "${solace_broker_nodes[0].private_ip_address}",
        "vpn_name": "sdkperf",
        "client_user_name": "testUsr",
        "client_user_name_pwd": "solace123"
      }
    },
    "hosts": {
      "broker_centos": {
        "ansible_host": "${solace_broker_nodes[0].public_ip_address}",
        "ansible_user": "${solace_broker_nodes[0].admin_username}",
        "ansible_become": true,
        "ansible_python_interpreter": "/usr/bin/python",
        "boxname":"broker-1"
      },
      "broker_pubsub": {
        "ansible_connection": "local",
        "sempv2_host": "${solace_broker_nodes[0].public_ip_address}",
        "sempv2_port": 8080,
        "sempv2_is_secure_connection": false,
        "sempv2_username": "admin",
        "sempv2_password": "admin",
        "sempv2_timeout": "60",
        "virtual_router": "primary"
      }
    }
  },
  "sdkperf_publishers": {
    "hosts": {
      "sdkperf_publisher_vm_0": {
        "ansible_host": "${sdk_perf_nodes[0].public_ip_address}",
        "ansible_user":"${sdk_perf_nodes[0].admin_username}",
        "ansible_python_interpreter": "/usr/bin/python",
        "boxname":"publisher-1"
      }
    }
  },
  "sdkperf_consumers": {
    "hosts": {
      "sdkperf_consumer_vm_1": {
        "ansible_host": "${sdk_perf_nodes[1].public_ip_address}",
        "ansible_user":"${sdk_perf_nodes[1].admin_username}",
        "ansible_python_interpreter": "/usr/bin/python",
        "boxname":"consumer-1"
      },
      "sdkperf_consumer_vm_2": {
        "ansible_host": "${sdk_perf_nodes[2].public_ip_address}",
        "ansible_user":"${sdk_perf_nodes[2].admin_username}",
        "ansible_python_interpreter": "/usr/bin/python",
        "boxname":"consumer-2"
      }
    }
  },
  "sdkperf_latency": {
    "hosts": {
      "sdkperf_latency_vm_3": {
        "ansible_host": "${sdk_perf_nodes[3].public_ip_address}",
        "ansible_user":"${sdk_perf_nodes[3].admin_username}",
        "ansible_python_interpreter": "/usr/bin/python",
        "boxname":"latency-1"
      }
    }
  }
}
