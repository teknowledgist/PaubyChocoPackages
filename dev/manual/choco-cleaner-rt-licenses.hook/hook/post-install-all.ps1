﻿$ErrorActionPreference = 'Continue'
# Choco-Cleaner-RT-licenses.hook v0.1.0 Copyleft 2023 by Bill Curran AKA BCURRAN3
# LICENSE: GNU GPL v3 - https://www.gnu.org/licenses/gpl.html
# Suggestions? Problems? Open a GitHub issue at https://github.com/bcurran3/ChocolateyPackages/issues

$HookName    = "Choco-Cleaner-RT (licenses)"
$ConfigFile  = "$(Get-ToolsLocation)\BCURRAN3\choco-cleaner-rt.config"
$LogFile     = "$(Get-ToolsLocation)\BCURRAN3\choco-cleaner-rt.log"
$DebugInfo   = $False
$DisplayInfo = $True
$LogInfo     = $False

# All license text types
$license_types = @( "license.txt","*.license.txt","verification.txt" )

if (Test-Path "$ConfigFile"){
    [xml]$Config = Get-Content "$ConfigFile"
	if ($Config.Settings.Preferences.DebugInfo -eq "true") {$DebugInfo=$True} else {$DebugInfo=$False}
    if ($Config.Settings.Preferences.DisplayInfo -eq "true") {$DisplayInfo=$True} else {$DisplayInfo=$False}
    if ($Config.Settings.Preferences.LogInfo -eq "true") {$LogInfo=$True} else {$LogInfo=$False}
}

if ($DebugInfo) { Write-Host "  ** Running $HookName..." -Foreground Yellow }

if (!(Test-Path "$(Get-ToolsLocation)\BCURRAN3")) {$LogInfo=$False}

function Add2Log {
    Param ( [string]$comment )
	
	if ($LogInfo) {
		Write-Output "$(Get-Date) [INFO ] $comment" >> "$LogFile"
	}
}

if (Test-ProcessAdminRights) {
	$GotLicenseFiles=Get-ChildItem -Path $env:packageFolder -Recurse -Include $license_types -ErrorAction SilentlyContinue
	$LicenseFiles=$GotLicenseFiles.count
	if ($LicenseFiles -ge 1){
		$GotLicenseFiles | ForEach-Object {$GotLicenseFilesSize=$GotLicenseFilesSize + $_.length}
		$GotLicenseFilesSize = $(($GotLicenseFilesSize/1kb).ToString('N0'))
		Remove-Item -Path $env:packageFolder -Recurse -Include $license_types -ErrorAction SilentlyContinue
		$GotLicenseFiles.fullname | ForEach-Object {Add2Log "DELETED: $_"}
		if ($DisplayInfo){
		    Write-Host "  ** $HookName`: Deleted $LicenseFiles unnecessary Chocolatey package embedded license files saving $GotLicenseFilesSize KB." -Foreground Green
		}
	}
} else {
	if ($DisplayInfo){ Write-Host "  ** $HookName requires admin rights." } -Foreground Yellow
}
