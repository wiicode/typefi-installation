#Requires -RunAsAdministrator
<#
ABOUT THIS SCRIPT:
Installs a complete Typefi Workgroup solution on a Windows Server.
#>

<#
SECURITY STATEMENT:
This script depends on FTP credentials, sample creds are stored in a plain text.
#>

<#
Typefi auditing block. It should be part of every script. 
#>
$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:currentfile = $MyInvocation.MyCommand.Name #you can use Path to get the full path.
$global:logfile = "$PSScriptRoot\$currentfile.txt" #this is where we keep our stuff.
Start-Transcript -Path $logfile
Write-Host "-.. . -... ..- --.DEBUG Callsign: ALPHA"
Write-Host "-.. . -... ..- --.DEBUG Logfile:" $logfile

<#
GLOBALS
#>
$global:hostname = $env:COMPUTERNAME
$global:typefi = "c:\ProgramData\Typefi"
## Edit this as needed
$global:ids2019 = "Registry::HKEY_CLASSES_ROOT\CLSID\{CE7A178C-C019-4749-8FA5-45A847E01EAF}\LocalServer32"
$global:ids2018 = "Registry::HKEY_CLASSES_ROOT\CLSID\{74812DB7-FA97-43E0-97F5-87D1E47B76E4}\LocalServer32"
$global:ids2017 = "Registry::HKEY_CLASSES_ROOT\CLSID\{C62D9F67-2815-4C5D-9754-5CEAA121CDD8}\LocalServer32"
#
## Edit these as needed ###
$global:mathtools_version = "3_0_1_058" #Example: "3_0_1_055"
$global:mathtools_url = "http://movemen.com/files/downloads/mtv3/058" #do not add trailing slash, example: "http://movemen.com/files/downloads/mtv3/055"
$global:idsVersions = @("$ids2019","$ids2018","$ids2017") #example, "$ids2019","$ids2018","$ids2017"
#

<#
FUNCTIONS
#>

    <# function name debug - start #>
    #Write-Host "-.. . -... ..- --.DEBUG function: "
    #write-FunctionName
    <# function name debug# - end #>
Function write-FunctionName
{
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
}

function setWorkingVolume {

  #WHERE ARE WE INSTALING?
  $testVolumeD = Test-Path D:
  $testVolumeC = Test-Path C:
  If ($testVolumeD -eq $True)
    {
      $global:payload = "D:\PAYLOAD"
    }
  If ($testVolumeC -eq $True)
    {
      $global:payload = "C:\PAYLOAD"
    }
  Else
    {
      Write-Host "Something is terribly wrong here."
    }


}

function read_system {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    $global:system= convertfrom-stringdata (get-content $PSScriptRoot/conf/system.conf -raw)
    $system
}

function read_ftp {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    $global:ftp = convertfrom-stringdata (get-content $PSScriptRoot/conf/ftp.conf -raw)
    $ftp

}

function read_manifest {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    $global:manifest= convertfrom-stringdata (get-content $PSScriptRoot/conf/manifest.conf -raw)
    $manifest

}

function read_manifest_plugins {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    ((Get-Content -path $PSScriptRoot/conf/plugins_install.txt) -replace '#','%23') | Set-Content -Path $PSScriptRoot/conf/plugins_install.txt
    [string[]]$global:manifest_plugins= get-content -Path $PSScriptRoot/conf/plugins_install.txt 
    $manifest_plugins
    ((Get-Content -path $PSScriptRoot/conf/plugins_install.txt) -replace '%23','#') | Set-Content -Path $PSScriptRoot/conf/plugins_install.txt
    [string[]]$global:manifest_plugins_original = get-content -Path $PSScriptRoot/conf/plugins_install.txt 
    $manifest_plugins_original
}

function service-stop ($serviceName){

If (Get-Service $serviceName -ErrorAction SilentlyContinue) {

    If ((Get-Service $serviceName).Status -eq 'Running') {

        Stop-Service $serviceName
        Write-Host "Stopping $serviceName"

    } Else {

        Write-Host "$serviceName found, but it is not running."

    }

} Else {

    Write-Host "$serviceName not found"

}

}

function service-start ($serviceName){

If (Get-Service $serviceName -ErrorAction SilentlyContinue) {

    If ((Get-Service $serviceName).Status -eq 'Stopped') {

        Start-Service $serviceName
        Write-Host "Starting $serviceName"

    } Else {

        Write-Host "$serviceName found, but it is running."

    }

} Else {

    Write-Host "$serviceName not found"

}

}


function go_server {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    write-host "-.. . -... ..- --.DEBUG: $($manifest.server)"
    $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_workgroup_install.txt"
    $installer =  "$PSScriptRoot\staging\$($manifest.server)"
    $arguments = "/x // /l*v $installer_log"
    Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait
    Remove-Item $PAYLOAD -Force -Recurse
    Remove-Item $typefi -Force -Recurse
    Remove-Item $installer -Force
    Get-ChildItem $PSScriptRoot\staging -Force -Filter typefi-plugin* | Remove-Item -Recurse
    }

function go_designer {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_designer_install.txt"
    $installer =  "$PSScriptRoot\staging\$($manifest.designer)"
    $arguments = "/x // /l*v $installer_log"
    Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait
    Remove-Item $installer -Force
}

function go_typefitter {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_typefitter_install.txt"
    $installer =  "$PSScriptRoot\staging\$($manifest.typefitter)"
    $arguments = "/x // /l*v $installer_log"
    Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait
    Remove-Item $installer -Force
}


function go_mathtools{
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)

    foreach ($idsVer in $idsVersions) {
    "$idsVer = " + $idsVer.length
    Write-Host "-.. . -... ..- --.DEBUG: Trying InDesign:" $idsVer

        If (Test-Path $idsVer)
            {
                Write-Host "$idsFound"
                $ids_path_exe = (Get-ItemProperty -LiteralPath "$idsVer").'(default)'
                Write-Host "-.. . -... ..- --.DEBUG: IDS EXE" $ids_path_exe
                $global:ids_path_dir = Split-Path -Path $ids_path_exe
                Write-Host "-.. . -... ..- --.DEBUG: IDS DIRECTORY" $ids_path_dir
                $global:idsYYYY = $ids_path_dir.substring($ids_path_dir.length - 4)
                Write-Host "-.. . -... ..- --.DEBUG: IDS YEAR" $idsYYYY
                #remove old MathTools
                Remove-Item $ids_path_dir\Plug-Ins\movemen -Force -Recurse
            }

        Else
            {

                Write-Host "-.. . -... ..- --.DEBUG: Did not find InDesign on this attempt."

            }

    #end of loop
    }

}


function stop_all_things {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    service-stop "InDesignServerService x64"
    service-stop "TypefiTomcat"

}


<#
MAIN BODY
#>
Write-Host " "
Write-Host "-.. . -... ..- --.DEBUG: Main Body."
Write-Host " ---------------------               --------------------- "
Write-Host " --------------------- SECTION START --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " "

#choose C if D is not present
setWorkingVolume
stop_all_things

#read properties
read_system
read_ftp
read_manifest
read_manifest_plugins
<#

If ($($system.property) -eq "true") {

}

#>


If ($($system.server) -eq "true") {
    go_server

}

If ($($system.designer) -eq "true") {
    go_designer

} 

If ($($system.typefitter) -eq "true") {
    go_typefitter

} 

If ($($system.mathtools) -eq "true") {
    go_mathtools

} 





else {
    
    write-host "-.. . -... ..- --.DEBUG: I have nothing to do." 
        
}



Write-Host " "
Write-Host " ---------------------               --------------------- "
Write-Host " --------------------- SECTION   END --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " "



<#
Typefi auditing block, end. It should be part of every script.
#>
Write-Host "-.. . -... ..- --.DEBUG : Arrived at the end!"
Stop-Transcript

exit 0