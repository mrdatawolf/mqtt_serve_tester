#!/bin/bash

# Function to generate a random number between 1 and 10
generate_random_number() {
  echo $(( ( RANDOM % 10 ) + 1 ))
}

# Function to send a message to a given topic
send_message() {
  local topic=$1
  local message=$2
  mosquitto_pub -h localhost -t "$topic" -m "$message"
}

# Variables
previous_number_test=$(generate_random_number)
previous_number_test2=$(generate_random_number)
interval_test=2
interval_test2=3

while true; do
  # Generate a new random number for 'test' topic within the allowed range
  new_number_test=$(( previous_number_test + ( RANDOM % 5 ) - 2 ))
  if [ $new_number_test -lt 1 ]; then
    new_number_test=1
  elif [ $new_number_test -gt 10 ]; then
    new_number_test=10
  fi

  # Generate a new random number for 'test2' topic within the allowed range
  new_number_test2=$(( previous_number_test2 + ( RANDOM % 5 ) - 2 ))
  if [ $new_number_test2 -lt 1 ]; then
    new_number_test2=1
  elif [ $new_number_test2 -gt 10 ]; then
    new_number_test2=10
  fi

  # Send the message to 'sensor1' topic
  send_message "sensor1" "$new_number_test"
  # Wait for the interval before sending the next message
  sleep $interval_test

  # Send the message to 'sensor 2' topic
  send_message "sensor 2" "$new_number_test2"
  # Wait for the interval before sending the next message
  sleep $interval_test2

  # Update the previous numbers
  previous_number_test=$new_number_test
  previous_number_test2=$new_number_test2
done