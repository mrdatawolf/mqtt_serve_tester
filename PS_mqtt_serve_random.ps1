# Ensure the PSMQTT module is installed and import it
if (-not (Get-Module -ListAvailable -Name PSMQTT)) {
    Install-Module -Name PSMQTT -Scope CurrentUser -Force
}
Import-Module PSMQTT

# Connect to the MQTT broker
$Session = Connect-MQTTBroker -Hostname '192.168.203.127' -Port 1883

# Function to send a message to a given topic
function Send-Message {
    param (
        [object]$session,
        [string]$topic,
        [string]$message
    )
    if ($session) {
        Send-MQTTMessage -Session $session -Topic $topic -Payload $message
    } else {
        Write-Error "MQTT session is not available."
    }
}

# Variables to keep track of the state
$lastFlowValue = Get-Random -Minimum 0 -Maximum 100
$lastCapValue = Get-Random -Minimum 0 -Maximum 100

# Function to generate a random switch state
# The switch state is a boolean value (0 or 1)
function Check-Switch {
    $newSwitchState = $null
    if (-not $lastSwitchState) {
        $newSwitchState = Get-Random -Minimum 0 -Maximum 2
    } else {
        $newSwitchState = Get-Random -Minimum 0 -Maximum 1
    }
    $lastSwitchState = $newSwitchState
    return $lastSwitchState
}

# Function to generate a random flow value with a maximum change of 3
function Check-Flow {
    $newFlowValue = $lastFlowValue + (Get-Random -Minimum -30 -Maximum 30)
    if ($newFlowValue -lt 0) {
        $newFlowValue = 0
    } elseif ($newFlowValue -gt 100) {
        $newFlowValue = 100
    }
    $lastFlowValue = $newFlowValue

    return $lastFlowValue
}

# Function to generate a random capacity value as a decimal number
function Check-Capacity {
    $newValue = $lastCapValue + (Get-Random -Minimum -20 -Maximum 20)
    if ($newValue -lt 0) {
        $newValue = 0
    } elseif ($newValue -gt 100) {
        $newValue = 100
    }
    $lastCapValue = $newValue

    return $lastCapValue / 100
}

# Variables
$intervalTest = 1
$intervalTest2 = 2
$intervalTest3 = 1
$intervalTest4 = 2

while ($true) {
    $switch1 = Check-Switch
    Send-Message -session $Session -topic "Switch1" -message ($switch1 | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest

    $flow1 = Check-Flow
    Send-Message -session $Session -topic "Flow1" -message ($flow1 | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest2

    $switch2 = $switch1 -eq 1
    Send-Message -session $Session -topic "Switch2" -message ($switch2 | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest3

    $capacity1 = Check-Capacity
    Send-Message -session $Session -topic "Capacity1" -message ($capacity1 | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest4
}