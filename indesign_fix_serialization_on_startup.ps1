<#
ABOUT THIS SCRIPT:
This script uses an ENV variable to re-serialize Adobe InDesign. This is useful as a scheduled task on startup.


USAGE:
First, change the properties on InDesignServerService x64 to "Automatic (Delayed Start)" as you want to execute this script on system start.

1) setup a system environemntal variable called "idskey" and save your InDesign Serial key to that variable.
2) setup a system environmental variable called "adobe_id" and enter your adobe ID (email address)
3) Set this up as a scheduled task using Windows Task Manager (run on startup) or using your favorite RMM. Make sure it runs as an admin.
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
$global:envidsserialtest = Test-Path Env:\idskey  #1155-0000-0000-0000-0000
$global:envadobeidtest = Test-Path Env:\adobe_id  #email@domain.com

$global:output_dir = "c:\ops\adobe"
$global:url = "https://www.dropbox.com/s/sre47lc9ndd38ms/adobe_prtk.exe?dl=1"
$global:installer = "adobe_prtk.exe"
$global:output = "$output_dir\$installer"

<#
FUNCTIONS
#>

Function serializeids
{
    write-host "DEBUG: Serialization taking place."
    Write-Host "DEBUG: Stopping InDesign $idsMajorVersion"
    Stop-Service -Name "InDesignServerService x64"
    Get-Process "InDesign*" | Stop-Process -Force

    Set-Location "$output_dir"
    CMD /C "adobe_prtk.exe --tool=Serialize --leid=V7{}InDesignServer-$idsMajorVersion-Win-GM --serial=$adobeserial --adobeid=$adobeid"
    Start-Sleep -s 5

    Write-Host "DEBUG: Starting InDesign $idsMajorVersion"
    Start-Service -Name "InDesignServerService x64"

}


Function serializeprep2
{
    write-host "DEBUG: Step 2, checking for required environmental variable called adobe_id."

    If ($envadobeidtest -eq $True)
        {
            Write-Host "DEBUG: Environmental Variable adobe_id detected, OK to continue."
            $global:adobeid = $Env:adobe_id
            Write-Host "DEBUG: AdobeID: " $adobeid
        }
    else
        {
            Write-Host "DEBUG: FAILURE! Environmental Variable adobe_id is missing. Please set it on the system."
            $global:adobeid = "NO-ADOBE-ID-FOUND"
            Write-Host "DEBUG: AdobeID: " $adobeid
            Write-Host "DEBUG: Calling function for Writing EVENTLOG ID 9987 with FAILURE notice."
            exit 0
        }

}



Function serializeprep1
{
    write-host "DEBUG: Step 1, checking for required environmental variable called IDSKEY."

    If ($envidsserialtest -eq $True)
        {
            Write-Host "DEBUG: Environmental Variable IDSKEY detected, OK to continue."
            $global:adobeserial = $Env:idskey
            Write-Host "DEBUG: Serial: " $adobeserial
        }
    else
        {
            Write-Host "DEBUG: FAILURE! Environmental Variable IDSKEY is missing. Please set it on the system."
            $global:adobeserial = "NO-SERIAL-FOUND"
            Write-Host "DEBUG: Serial: " $adobeserial
            Write-Host "DEBUG: Calling function for Writing EVENTLOG ID 9987 with FAILURE notice."
            exit 0
        }

}


Function maincode{


        #Retrieve the AdobeID and InDesignServer Serial Number, or fail gracefully.
        #serial number
        serializeprep1
        #adobe id
        serializeprep2

        #Figure out what we're using...
        Write-Host "DEBUG: "
        $regkey = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\InDesignServerService x64' -Name "ImagePath"
        $value = $regkey.ImagePath
        $path = $value.Replace("`"","")
        $folder = Split-Path -Path $path
        $global:idsMajorVersion = (Get-Item "$folder\InDesignServer.exe").VersionInfo.FileMajorPart
        Write-Host "DEBUG: Adobe InDesign Version in use is Version $idsMajorVersion"

        #Let's do it!
        serializeids


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
            maincode
        }

    else
        {

            Write-Host "adobe_prkt missing, attempting to download from $url"
            $start_time = Get-Date
            New-Item -ItemType directory -Path $output_dir -Force
            Invoke-WebRequest -Uri $url -OutFile $output
            Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
            maincode

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