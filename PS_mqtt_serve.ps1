# Ensure the PSMQTT module is installed and import it
if (-not (Get-Module -ListAvailable -Name PSMQTT)) {
    Install-Module -Name PSMQTT -Scope CurrentUser -Force
}
Import-Module PSMQTT

# Connect to the MQTT broker
$Session = Connect-MQTTBroker -Hostname '127.0.0.1' -Port 1883

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

# Function to check if an IP is alive
function Check-IPAlive {
    param (
        [string]$ip
    )
    $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet
    return $pingResult
}

# Function to check if a file exists
function Check-FileExists {
    param (
        [string]$filePath
    )
    return Test-Path $filePath
}

# Variables
$intervalTest = 2
$intervalTest2 = 3
$dateToday = Get-Date -Format "yyyyMMdd"

while ($true) {
    # Check if IP is alive
    $ipAlive = Check-IPAlive -ip "127.0.0.1"
    Send-Message -session $Session -topic "ip_alive" -message ($ipAlive | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest

    # Check if file exists
    $filePath = "C:\Windows\Temp\mqtt_labels_test_$dateToday.txt"
    $fileExists = Check-FileExists -filePath $filePath
    Send-Message -session $Session -topic "file_exists" -message ($fileExists | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest2
}