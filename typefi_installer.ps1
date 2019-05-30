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


function ftp_file ([string]$filename, [string]$filepath) {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    write-host "-.. . -... ..- --.DEBUG: filename is $filename"
    write-host "-.. . -... ..- --.DEBUG: filepath is $filepath"
    $ftp_assembly = "ftp://$($ftp.user):$($ftp.pass)@$($ftp.server)/$filepath/$filename"
    write-host "-.. . -... ..- --.DEBUG: url is $ftp_assembly"
    $webclient = New-Object System.Net.WebClient
    $uri = New-Object System.Uri($ftp_assembly)
    $saveto = "$PSScriptRoot\staging\$filename"
    "-.. . -... ..- --.DEBUG: saving file: $saveto"
    $webclient.DownloadFile($uri, "$saveto")

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


function go_distraction {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Unrestricted -File $PSScriptRoot\bin\distraction\rickrolled.ps1" 
    
}


function go_server {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)

    If (test-path $typefi) {

        service-stop "TypefiTomcat"
        write-host "-.. . -... ..- --.DEBUG: $($manifest.server)"
        ftp_file $manifest.server "Typefi__Server for Workgroup"
        $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_workgroup_upgrade.txt"
        $installer =  "$PSScriptRoot\staging\$($manifest.server)"
        $arguments = "/qn /l*v $installer_log"
        Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait
    }

    else {

        service-stop "TypefiTomcat"
        write-host "-.. . -... ..- --.DEBUG: $($manifest.server)"
        ftp_file $manifest.server "Typefi__Server for Workgroup"
        $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_workgroup_install.txt"
        $installer =  "$PSScriptRoot\staging\$($manifest.server)"
        $arguments = "APPDIR=$payload\Typefi /qn /l*v $installer_log"
        Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait
        Set-Service -Name TypefiTomcat -Computer $hostname -StartupType "Automatic"
    }
   
}

function go_override_config {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    Copy-Item "$PSScriptRoot\bin\typefi_config\*.*" -Destination "$typefi" -Verbose -Recurse -Force


}

function go_designer {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    service-stop "InDesignServerService x64"
    ftp_file $manifest.designer "Typefi__Designer Server"
    $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_designer_install.txt"
    $installer =  "$PSScriptRoot\staging\$($manifest.designer)"
    $arguments = "APPDIR=$payload\Typefi /qn /l*v $installer_log"
    Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait
}

function go_typefitter {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    service-stop "InDesignServerService x64"
    ftp_file $manifest.typefitter "Typefi__Typefitter"
    $installer_log = "$PSScriptRoot\logs\bootstrap_typefi_typefitter_install.txt"
    $installer =  "$PSScriptRoot\staging\$($manifest.typefitter)"
    $arguments = "APPDIR=$payload\Typefi /qn /l*v $installer_log"
    Start-Process $installer -ArgumentList $arguments -Verb runAs -Wait

}


function go_plugins {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    service-stop "TypefiTomcat"

    Get-ChildItem $PSScriptRoot\staging -Force -Filter typefi-plugin* | Remove-Item -Recurse
    Get-ChildItem $PAYLOAD\Typefi\Server\webapps -Force -Filter typefi-plugin* | Remove-Item -Recurse
    
    ForEach ($file in $manifest_plugins){
        Write-host "-.. . -... ..- --.DEBUG: Requesting $file" 
        ftp_file $file "Typefi__Server Plugins/latest"
    }

    Get-ChildItem -Path $PSScriptRoot\staging | Rename-Item -NewName { $_.Name -replace '%23','#' }
    Copy-Item "$PSScriptRoot\staging\*.war" -Destination "$PAYLOAD\Typefi\Server\webapps" -Verbose -Recurse -ErrorAction Continue

}


function go_mathtools{
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)  
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Unrestricted -File $PSScriptRoot\mathtools_installer.ps1" -verb RunAs -Wait

}


function go_demos {
    write-Host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    $fs_path = "$typefi\Filestore.properties"
    $fs_values = Get-Content $fs_path | Out-String | ConvertFrom-StringData
    $dest = "$($fs_values.FILESTORE_LOC)"
    Copy-Item "$PSScriptRoot\bin\typefi_demos\*" -Destination $dest -Verbose -Recurse -Force
    
}


function go_harvest {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Unrestricted -File $PSScriptRoot\typefi_harvester.ps1" -verb RunAs -Wait

}

function start_all_things {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    service-start "InDesignServerService x64"
    service-start "TypefiTomcat"

}

function go_launchchrome {
    write-host ("-.. . -... ..- --.DEBUG: The name of this function is: {0} " -f $MyInvocation.MyCommand)
    Start-Sleep -s 10
    Start "http://$hostname:8080"

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

#read properties
read_system
read_ftp
read_manifest
read_manifest_plugins
<#

If ($($system.property) -eq "true") {

}

#>

If ($($system.distraction) -eq "true") {
    go_distraction
}

If ($($system.server) -eq "true") {
    go_server

} 

If ($($system.override_config) -eq "true") {
    go_override_config
} 

If ($($system.plugins) -eq "true") {
    go_plugins

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

If ($($system.startup) -eq "true") {
    start_all_things
} 

If ($($system.demos) -eq "true") {
    go_demos
} 

If ($($system.harvest) -eq "true") {
    go_harvest

} 

If ($($system.launchchrome) -eq "true") {
    go_launchchrome

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