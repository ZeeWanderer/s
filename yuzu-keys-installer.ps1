param
(
	[Switch]$wizard,
	[Switch]$update,
	
	[Switch]$install_yuzu,
	[Switch]$install_keys,
	[Switch]$install_sa
)

"Yuzu Keys Installer"

$location = Get-Location

$ProgressPreference = 'silentlyContinue'

function cancel()
{
	"Thanks to /u/yuzu_pirate, /u/Azurime, and /u/bbb651 for their contributions to /r/YuzuP I R A C Y."
	"This program made by /u/Hipeopeo."
	"Thanks to the yuzu devs for making Yuzu!"
	Set-Location $location
	if($wizard -eq $true){pause}
	exit
}

if($wizard -eq $true)
{
	$install_keys = $true
	$install_sa = $true
	while($true)
	{
		$menu = (Read-Host -Prompt 'Do you want to update script? (Y/N)').ToLower()
		if ($menu -eq "y") 
		{
			$update = $true
			break
			#goto UY
		}
		if ($menu -eq "n") {break} #goto A
		else 
		{
			"Invalid input. Please try again."
		}
	}

	while($true) #:A 
	{
		$menu = (Read-Host -Prompt 'Do you want to install Yuzu? (Y/N/Cancel)').ToLower()
		if ($menu -eq 'y') 
		{
			$install_yuzu = $true
			break
		}
		if ($menu -eq 'n') {break } #goto No
		if ($menu -eq 'c') {cancel} #goto c
		if ($menu -eq 'system archives') 
		{
			$install_keys = $false
			break #goto SA
		}
		if ($menu -eq 'sa') 
		{
			$install_keys = $false
			break #goto SA
		}
		else
		{ 
			"Invalid input. Please try again..."
			Continue
		}
		break
	}

	while($true) #:A 
	{
		$menu = (Read-Host -Prompt 'Do you want to install System Archives? (Y/N)').ToLower()
		if ($menu -eq 'y') 
		{
			break
		}
		if ($menu -eq 'n') 
		{
			$install_sa = $false
			break
		}
		else
		{ 
			"Invalid input. Please try again..."
			Continue
		}
		break
	}
}

if($update) #:UY 
{
	"Updating"
	"`n"
	"Downloading new version..."
	try
	{
		Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/zeewanderer/s/master/yuzu-keys-installer.ps1' -OutFile 'yuzu-keys-installer.ps1'
		if($wizard -eq $true)
		{
			"Starting updated script"
			powershell -file "yuzu-keys-installer.ps1" -wizard
		}
	}
	catch
	{
		"Exiting due to error in :UY"
		exit
	}
}


if($install_yuzu) #:Yes 
{
	"`n"
	"This will download the Yuzu installer, and run it. Allow it to install."
	"`n"
	if(Test-Path "yuzu_install.exe")
	{
		"Removing old version..."
		Remove-Item "yuzu_install.exe"
	}
	try
	{
		$reply = Invoke-WebRequest "https://api.github.com/repos/yuzu-emu/liftinstall/releases/latest"

		if($reply.StatusDescription -eq "OK")
		{
			$url = (ConvertFrom-Json $reply).assets.browser_download_url
			Invoke-WebRequest -ContentType "application/octet-stream" -Uri $url -OutFile 'yuzu_install.exe'
			"We will now install yuzu, then delete the installer."
			Start-Process "yuzu_install.exe" -Wait
		}
		else
		{
			throw $reply
		}
	}
	catch
	{
		"Error encountered in :Yes"
		"Cleaning up..."
	}
	Remove-Item "yuzu_install.exe" | out-null
	Remove-Item "yuzu_installer.log" | out-null
	"Done."
}

if($install_keys) #:No 
{
	"Okay, that means it's time to download the keys."
	"`n"
	"We will now download the keys."
	Set-Location "$env:appdata\yuzu"
	if((Test-Path "keys\prod.keys") -or (Test-Path "keys\title.keys"))
	{
		"Deleting old keys..."
		Remove-Item "keys" -Recurse -Force
	}
	(New-Item -Name "keys" -ItemType directory) | out-null
	Set-Location "keys"
	"Writing new keys to $env:appdata\yuzu\keys"
	try
	{
		Invoke-WebRequest -ContentType "application/octet-stream" -Uri 'https://raw.githubusercontent.com/zeewanderer/s/master/prod.keys' -OutFile 'prod.keys'
		Invoke-WebRequest -ContentType "application/octet-stream" -Uri 'https://raw.githubusercontent.com/zeewanderer/s/master/title.keys' -OutFile 'title.keys'
	}
	catch
	{
		"Error in :No"
	}
	"Successfully downloaded title.keys, prod.keys"
}

if($install_sa) #:SA 
{
	"`n"
	"We will now download the System Archives. This may take a while..."
	Set-Location "$env:appdata\yuzu\nand\system"
	try
	{
		Invoke-WebRequest -ContentType "application/octet-stream" -Uri 'https://www.dropbox.com/s/0gwmpgus9t4q1dm/System_Archives.zip?dl=1' -OutFile 'System_Archives.zip'
		"unzipping System Archives."
		Invoke-WebRequest -ContentType "application/octet-stream" -Uri 'https://www.dropbox.com/s/wcdhkat6oz0i3tm/unzip.exe?dl=1' -OutFile 'unzip.exe'
		"Writing System Archives to $env:appdata\yuzu\keys\nand\system"
		.\unzip.exe -o "System_Archives.zip"
	}
	catch
	{
		"Fatal error in :SA, cleaning up and exiting"
	}
	"Cleaning up..."
	Remove-Item "System_Archives.zip" | out-null
	Remove-Item "unzip.exe" | out-null
}

cancel #:c 
