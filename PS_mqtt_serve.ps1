if (-not (Get-Module -ListAvailable -Name PSMQTT)) {
    Install-Module -Name PSMQTT -Scope CurrentUser -Force
}
Import-Module PSMQTT
$Session = Connect-MQTTBroker -Hostname '192.168.203.223' -Port 1883
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
function Check-IPAlive {
    param (
        [string]$ip
    )
    $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet
    return $pingResult
}
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
    $ipAlive = Check-IPAlive -ip "192.168.203.130"
    Send-Message -session $Session -topic "test\ip_alive" -message ($ipAlive | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest
    $filePath = "C:\Windows\Temp\mqtt_export_test_$dateToday.txt"
    $fileExists = Check-FileExists -filePath $filePath
    Send-Message -session $Session -topic "test\export_file_exists" -message ($fileExists | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest2
    $filePath = "C:\Windows\Temp\mqtt_report_test_$dateToday.txt"
    $fileExists = Check-FileExists -filePath $filePath
    Send-Message -session $Session -topic "report_file_exists" -message ($fileExists | ConvertTo-Json)
    Start-Sleep -Seconds $intervalTest3
}