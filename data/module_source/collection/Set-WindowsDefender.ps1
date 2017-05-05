function Set-WindowsDenfender {param ([string]$Enable)

$banner = @'
           _                _           _                       _       __                _           
  ___  ___| |_    __      _(_)_ __   __| | _____      _____  __| | ___ / _| ___ _ __   __| | ___ _ __ 
 / __|/ _ \ __|___\ \ /\ / / | '_ \ / _' |/ _ \ \ /\ / / __|/ _' |/ _ \ |_ / _ \ '_ \ / _' |/ _ \ '__|
 \__ \  __/ ||_____\ V  V /| | | | | (_| | (_) \ V  V /\__ \ (_| |  __/  _|  __/ | | | (_| |  __/ |   
 |___/\___|\__|     \_/\_/ |_|_| |_|\__,_|\___/ \_/\_/ |___/\__,_|\___|_|  \___|_| |_|\__,_|\___|_|   
`n                                                                                                      
'@

$resultado = $banner
$resultado += "`n                                                                   CyberVaca @ HackPlayers`n`n" 

if ($Enable -like "*True*") {Set-MpPreference -DisableIOAVProtection $False ; $resultado += "[+] Windows Defender right now is Enabled" ; return $resultado}
if ($Enable -like "*False*") {Set-MpPreference -DisableIOAVProtection $True ;$resultado += "[+] Windows Defender right now is Enabled" ; return $resultado}

}


