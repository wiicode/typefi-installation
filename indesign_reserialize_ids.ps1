<#
ABOUT THIS SCRIPT:
This script uses an ENV variable to re-serialize Adobe InDesign. This is useful as a scheduled task on startup.


USAGE:
First, change the properties on InDesignServerService x64 to "Automatic (Delayed Start)" as you want to execute this script on system start.

1) setup a system environemntal variable called "adobe_idsserial" and save your InDesign Serial key to that variable.
2) setup a system environmental variable called "adobe_id" and enter your adobe ID (email address)
3) Set this up as a scheduled task using Windows Task Manager (run on startup) or using your favorite RMM.
#>

<#
SECURITY STATEMENT:
Exposes InDesign keys.
#>

<#
Auditing block. It should be part of every script.
#>
$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:currentfile = $MyInvocation.MyCommand.Name #you can use Path to get the full path.
$timestamp = get-date -Format yyyyMMdd
$global:logfile = "c:\ops\logs\$currentfile-$timestamp.txt" #this is where we keep our stuff.
Start-Transcript -Path $logfile
Write-Host "-.. . -... ..- --.DEBUG Callsign: ALPHA"
Write-Host "-.. . -... ..- --.DEBUG Logfile:" $logfile

<#
GLOBALS
#>
$global:envidsserialtest = Test-Path Env:\adobe_idsserial  #1155-0000-0000-0000-0000
$global:envadobeidtest = Test-Path Env:\adobe_id  #1155-0000-0000-0000-0000
$global:ids2020 = "Registry::HKEY_CLASSES_ROOT\CLSID\{24F00A91-FA8D-442E-9A2F-146801EA5896}\LocalServer32"
#$global:ids2019 = "Registry::HKEY_CLASSES_ROOT\CLSID\{CE7A178C-C019-4749-8FA5-45A847E01EAF}\LocalServer32"
#$global:ids2018 = "Registry::HKEY_CLASSES_ROOT\CLSID\{74812DB7-FA97-43E0-97F5-87D1E47B76E4}\LocalServer32"
#$global:ids2017 = "Registry::HKEY_CLASSES_ROOT\CLSID\{C62D9F67-2815-4C5D-9754-5CEAA121CDD8}\LocalServer32"
$global:idsVersions = @("$ids2020") #example, "$ids2019","$ids2018","$ids2017"

$global:output_dir = "c:\ops\adobe"
$global:url = "https://www.dropbox.com/s/ssdeuh5n4ifuccw/adobe_prtk.exe?dl=1"
$global:installer = "adobe_prtk.exe"
$global:output = "$output_dir\$installer"

<#
FUNCTIONS
#>

Function serializeids2020
{
    write-host "Serialization taking place."
    Write-Host "DEBUG: Stopping InDesign 2020"
    Stop-Service -Name "InDesignServerService x64"
    Get-Process "InDesign*" | Stop-Process -Force

    Set-Location "$output_dir"
    CMD /C "adobe_prtk.exe --tool=Serialize --leid=V7{}InDesignServer-15-Win-GM --serial=$adobeserial --adobeid=$adobeid"
    Start-Sleep -s 5

    Write-Host "DEBUG: Starting InDesign 2020"
    Start-Service -Name "InDesignServerService x64"

}


Function serializeprep2
{
    write-host "Step 1, checking for required environmental variable called adobe_id."

    If ($envadobeidtest -eq $True)
        {
            Write-Host "Environmental Variable adobe_id detected, OK to continue."
            $global:adobeid = $Env:adobe_id
            Write-Host "Serial: " $adobeid
        }
    else
        {
            Write-Host "FAILURE! Environmental Variable adobe_id is missing. Please set it on the system."
            exit 0
        }

}



Function serializeprep1
{
    write-host "Step 1, checking for required environmental variable called adobe_idsserial."

    If ($envidsserialtest -eq $True)
        {
            Write-Host "Environmental Variable adobe_idsserial detected, OK to continue."
            $global:adobeserial = $Env:adobe_idsserial
            Write-Host "Serial: " $adobeserial
        }
    else
        {
            Write-Host "FAILURE! Environmental Variable adobe_idsserial is missing. Please set it on the system."
            exit 0
        }

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


    If (Test-Path $output)
        {
            Write-Host "adobe_prkt already present, skipping download"
            serializeprep1
            serializeprep2
            serializeids2020
        }

    else
        {

            Write-Host "adobe_prkt missing, attempting to download from $url"
            $start_time = Get-Date
            New-Item -ItemType directory -Path $output_dir -Force
            Invoke-WebRequest -Uri $url -OutFile $output
            Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

            serializeprep1
            serializeprep2
            serializeids2020
        }


Write-Host " "
Write-Host " ---------------------               --------------------- "
Write-Host " --------------------- SECTION   END --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " "





<#
auditing block, end. It should be part of every script.
#>
Write-Host "-.. . -... ..- --.DEBUG : Arrived at the end!"
Stop-Transcript
exit 0