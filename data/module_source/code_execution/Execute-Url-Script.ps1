function  execute-url-script {
param ($url)

$objeto = "system.net.webclient" 
$webclient = New-Object $objeto 
$webrequest = $webclient.DownloadString($url)
IEX $webrequest}
