# Load

## Configure
````bash
cd ../vars
vi sdkperf.vars.yml
# customize the following:
client_connection_count: 1 # 1 || 10 || 100 || 1000 || etc...
msg_payload_size_bytes: 100 # 100 || 1000 || 10000 || etc...
# total_msg_number:
msg_number: 100000000000 # how many total messages to send, but we don't want our test to stop until we tell it to via kill -2
# 0=max
msg_rate_per_second: 200000
# msg_rate_per_second: 160000
# msg_rate_per_second: 100000
````

#### Start Load
````bash
export UC_NON_PERSISTENT_INFRASTRUCTURE={cloud-provider}.{infrastructure}
# for example:
export UC_NON_PERSISTENT_INFRASTRUCTURE=azure.standalone
./start.load.sh
````
Or, pass the infrastrucure as an argument:
````bash
./start.load.sh azure.standalone
````
#### Stop Load

````bash
./stop.load.sh {with env var or arg as start.load.sh}
````


---
The End.
