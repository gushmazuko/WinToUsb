<#
.SYNOPSIS
	This script create a Bootable Windows USB Stick with UEFI support
	
.NOTES
	Function   : WinToUsb
	File Name  : WinToUsb.ps1
	Author     : Gushmazuko

.LINK
	https://github.com/gushmazuko/WinToUsb

.EXAMPLE
	#Run PowerShell as Admin
	powershell -exec bypass
	Import-Module WinToUsb.ps1
	WinToUsb
	
	#OR
	#Run PowerShell as Admin
	powershell -exec bypass "iwr -useb 'https://raw.githubusercontent.com/gushmazuko/WinToUsb/master/WinToUsb.ps1'|iex;WinToUsb"
#>

function WinToUSB(){
	clear

	#Show mounted disks
	Get-Disk
	#Select Disk
	Write-Host "`nWARNING! BE VERY CAREFUL WHEN SELECTING A DISK" -ForegroundColor Red
	Do {Write-Host " - [Select Usb Flash to erase] : " -ForegroundColor Green -NoNewline
		$DiskNumber = Read-Host}
		While ($DiskNumber -eq "")
	
	#Erase all data on the flash drive
	Get-Disk $DiskNumber | Clear-Disk -RemoveData

	#Create new partition, assign a letter & format it to FAT32
	New-Partition -DiskNumber $DiskNumber -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem FAT32
	
	#Set a partition active so the BIOS/UEFI can boot to it
	Set-Partition -DiskNumber $DiskNumber -PartitionNumber 1 -IsActive $true
	
	#Copying Windows files to USB drive
		
		#Getting USB Drive Path
		$UsbLetter = Get-Partition -DiskNumber $DiskNumber | select -ExpandProperty DriveLetter
		$UsbPath = "$($UsbLetter):\"
		
		#Getting Windows Files Path
		Do {Write-Host " - [Write path where Windows Image is mounted] : " -ForegroundColor Green -NoNewline
			$WinPath = Read-Host}
			While ($WinPath -eq "")
	
	robocopy $WinPath $UsbPath /mir
	
	cd $WinPath\boot
	.\bootsect.exe /nt60 "$($UsbLetter):"
	
}
