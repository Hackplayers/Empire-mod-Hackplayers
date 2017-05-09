# Empire-mod-Hackplayers

PowerShell Empire mod to post-exploit the World!

       ====================================================================================
        Empire: PowerShell post-exploitation agent | [Version]: 2.0 Mod: HackPlayers 
       ====================================================================================
        [Web]: https://www.PowerShellEmpire.com/ | [Twitter]: @harmj0y, @sixdub, @enigma0x3
       ====================================================================================
       
        __    __       ___       ______  __  ___                
       |  |  |  |     /   \     /      ||  |/  /                
       |  |__|  |    /  ^  \   |  ,----'|  '  /                 
       |   __   |   /  /_\  \  |  |     |    <                  
       |  |  |  |  /  _____  \ |  `----.|  .  \                 
       |__|  |__| /__/     \__\ \______||__|\__\                
        _______ .___  ___. .______    __  .______       _______ 
       |   ____||   \/   | |   _  \  |  | |   _  \     |   ____|
       |  |__   |  \  /  | |  |_)  | |  | |  |_)  |    |  |__   
       |   __|  |  |\/|  | |   ___/  |  | |      /     |   __|  
       |  |____ |  |  |  | |  |      |  | |  |\  \----.|  |____ 
       |_______||__|  |__| | _|      |__| | _| `._____||_______|  Mod: HackPlayers
       
       
       207 modules currently loaded
       
       0 listeners currently active
       
       0 agents currently active
       
       (Empire) > 

# Modules added

&nbsp;&nbsp;&nbsp;**BypassUAC-HackPlayers-eventvwr.ps1**&nbsp;&nbsp;	(BypassUAC using eventvwr working in Windows 7/8/10)  
&nbsp;&nbsp;&nbsp;**Invoke-Mimikittenz**&nbsp;&nbsp;(Using Windows function ReadProcessMemory() in order to extract plain-text passwords)  
&nbsp;&nbsp;&nbsp;**Invoke-Mimigatoz**&nbsp;&nbsp; (Variant of Mimikatz)  
&nbsp;&nbsp;&nbsp;**Keylogger_selective**&nbsp;&nbsp;	(Executes a keylogger selectively)  
&nbsp;&nbsp;&nbsp;**PsBoTelegram**&nbsp;&nbsp; (Backdoor controlled from telegram)  
&nbsp;&nbsp;&nbsp;**Execute-Url-Script**&nbsp;&nbsp; (Run scripts from a file in a url)  
&nbsp;&nbsp;&nbsp;**Sherlock**&nbsp;&nbsp; (Find privilege escalation vulnerabilities)  
&nbsp;&nbsp;&nbsp;**MS16-135**&nbsp;&nbsp; (Exploit privilege escalation MS16-135 x64 by b33f FuzzySecurity)  
&nbsp;&nbsp;&nbsp;**Invoke-HostRecon**&nbsp;&nbsp; (Situational Awareness)  
&nbsp;&nbsp;&nbsp;**Binder-4System**&nbsp;&nbsp; (Get System from service process)  
&nbsp;&nbsp;&nbsp;**Invoke-Phant0m**&nbsp;&nbsp; (Stops threads from the svhost process to prevent it from logging events without stopping the service.)  
&nbsp;&nbsp;&nbsp;**Set-WindowsDefender**&nbsp;&nbsp; (We can disabled and enabled Windows Defender silently)  


# Install in Debian

    git clone https://github.com/hackplayers/empire-mod-hackplayers.git
    cd empire-mod-hackplayers/setup/
    sudo apt-get update > /dev/null
    ./install.sh
    cd ..
    ./empire
    
 # Install in Arch
     git clone https://github.com/hackplayers/empire-mod-hackplayers.git
     cd empire-mod-hackplayers
     yaourt -S swig2
     sudo ln -s /usr/bin/swig-2 /usr/bin/swig
     pip install pycrypto iptools pydispatcher m2crypto m2ext
     sudo rm /usr/bin/swig
     cd setup
     python setup_database.py
     ./cert.sh
     cd ..
     python empire.py
     
![empire_mod_hackplayers.png logo](./empire_mod_hackplayers.png)  
