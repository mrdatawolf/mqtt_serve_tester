# mqtt_serve_tester
 sets up a mqtt server with some simple data to test against

mqtt_serve.sh:
## This script generates random numbers between 1 and 10 for two MQTT topics: 'sensor1' and 'sensor 2'.
## It sends these numbers at specified intervals, ensuring that the numbers stay within the range of 1 to 10.
## The script uses mosquitto_pub to publish messages to the MQTT broker running on localhost. 

PS_display.ps1
## This script creates a simple Windows Forms application that connects to an MQTT broker and displays the status

PS_mqtt_serve_prod_counts.ps1
## This PowerShell script is designed to simulate and send production count data from various machines to an MQTT broker using the PSMQTT module. 

PS_mqtt_server_random.ps1
## This PowerShell script connects to an MQTT broker and sends random values for switch states, flow values, and capacity values at regular intervals.  

PS_mqtt_serve.ps1
## This script is designed to run an MQTT server that simulates a flow and capacity system.
## It connects to two MQTT brokers and sends random values for switches, flow, and capacity. 