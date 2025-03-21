Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module PSMQTT

# Function to create the form
function Create-Form {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "MQTT Monitor"
    $form.Size = New-Object System.Drawing.Size(300, 200)
    return $form
}

# Function to create a light
function Create-Light {
    param (
        [int]$x,
        [int]$y
    )
    $light = New-Object System.Windows.Forms.Panel
    $light.Size = New-Object System.Drawing.Size(50, 50)
    $light.Location = New-Object System.Drawing.Point($x, $y)
    $light.BackColor = [System.Drawing.Color]::Red  # Default to red
    return $light
}

# Function to update the light color
function Update-LightColor {
    param (
        [System.Windows.Forms.Panel]$light,
        [bool]$status
    )
    if ($status) {
        $light.BackColor = [System.Drawing.Color]::Green
    } else {
        $light.BackColor = [System.Drawing.Color]::Red
    }
    Write-Host "Updated light color to" $light.BackColor.Name "for status" $status
}

# Function to handle MQTT messages
function Handle-MQTTMessage {
    param (
        [string]$topic,
        [string]$message,
        [System.Windows.Forms.Panel]$light1,
        [System.Windows.Forms.Panel]$light2
    )
    if ($topic -eq "ip_alive") {
        Update-LightColor -light $light1 -status ($message -eq "true")
    } elseif ($topic -eq "file_exists") {
        Update-LightColor -light $light2 -status ($message -eq "true")
    }
}

# Function to setup MQTT client
function Setup-MQTTClient {
    param (
        [string]$brokerAddress,
        [System.Windows.Forms.Panel]$light1,
        [System.Windows.Forms.Panel]$light2
    )
    $session = Connect-MQTTBroker -Hostname $brokerAddress -Port 1883
    $session.Subscribe("ip_alive")
    $session.Subscribe("file_exists")
    return $session
}

# Create the form and lights
$form = Create-Form
$light1 = Create-Light -x 50 -y 50
$light2 = Create-Light -x 150 -y 50
$form.Controls.Add($light1)
$form.Controls.Add($light2)
$broker_address = "127.0.0.1"

# Setup MQTT client
$mqttSession = Setup-MQTTClient -brokerAddress $broker_address -light1 $light1 -light2 $light2
Write-Host "Test 3"
Pause
# Timer to keep the form responsive and process MQTT messages
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000  # Check every second
$timer.Add_Tick({
    while ($mqttSession.MessageQueue.Count -gt 0) {
        $message = $mqttSession.MessageQueue.Dequeue()
        Handle-MQTTMessage -topic $message.Topic -message $message.Payload -light1 $light1 -light2 $light2
    }
})
$timer.Start()

# Show the form
[void]$form.ShowDialog()

# Disconnect the MQTT client when the form is closed
$form.Add_FormClosed({
    $mqttSession.Disconnect()
})