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
$intervalTest3 = 5
$dateToday = Get-Date -Format "yyyyMMdd"

while ($true) {
    # Check if IP is alive
    $ipAlive = Check-IPAlive -ip "192.168.203.127"
    Send-Message -session $Session -topic "ip_alive" -message ($ipAlive | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest

    # Check if export file exists
    $filePath = "C:\Windows\Temp\mqtt_export_test_$dateToday.txt"
    $fileExists = Check-FileExists -filePath $filePath
    Send-Message -session $Session -topic "export_file_exists" -message ($fileExists | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest2

    # Check if report  file exists
    $filePath = "C:\Windows\Temp\mqtt_report_test_$dateToday.txt"
    $fileExists = Check-FileExists -filePath $filePath
    Send-Message -session $Session -topic "report_file_exists" -message ($fileExists | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest3
}