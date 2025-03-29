# Ensure the PSMQTT module is installed and import it
if (-not (Get-Module -ListAvailable -Name PSMQTT)) {
    Install-Module -Name PSMQTT -Scope CurrentUser -Force
}
Import-Module PSMQTT
#$SFPBroker = '192.168.203.127';
$BTBroker = '192.168.203.223';

# Connect to the MQTT broker
#$SFPSession = Connect-MQTTBroker -Hostname $SFPBroker -Port 1883
$BTSession = Connect-MQTTBroker -Hostname $BTBroker -Port 1883

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
$machineCounts = @{
    "Trimmer" = Get-Random -Minimum 50000 -Maximum 100000
    "Debarker" = Get-Random -Minimum 50000 -Maximum 100000
    "Twin" = Get-Random -Minimum 50000 -Maximum 100000
    "CutSaw" = Get-Random -Minimum 50000 -Maximum 100000
    "SharpChain" = Get-Random -Minimum 50000 -Maximum 100000
    "SingleResaw" = Get-Random -Minimum 50000 -Maximum 100000
    "GangEdger" = Get-Random -Minimum 50000 -Maximum 100000
    "Quad" = Get-Random -Minimum 50000 -Maximum 100000
    "GMachines" = Get-Random -Minimum 50000 -Maximum 100000
}

# Function to generate a random production count
function Set-Count {
    param (
        [int]$currentValue
    )

    $newValue = $currentValue + (Get-Random -Minimum -20000 -Maximum 20000)
    if ($newValue -lt 0) {
        $newValue = 0
    } elseif ($newValue -gt 100000) {
        $newValue = 100000
    }

    return $newValue
}

while ($true) {
    $machineKeys = $machineCounts.Keys.Clone() # Create a copy of the keys
    foreach ($machine in $machineKeys) {
        $currentCount = $machineCounts[$machine]
        $newCount = Set-Count -currentValue $currentCount
        $machineCounts[$machine] = $newCount
        Send-Message -session $BTSession -topic "${machine}Count" -message ($newCount | ConvertTo-Json)
        Start-Sleep -Seconds 1
    }
}