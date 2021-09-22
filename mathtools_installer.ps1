# MathTools Installation script.
# This script cannot be used if switching major versions of InDesign Server.

$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:logfile = "c:\ops\logs\mathtools_upgrade_output.txt"
Start-Transcript -path $logfile -Append
Write-Host "Alpha"

########################################################
########################################################
## GLOBALS ##

$global:mathtools_version = "3_0_1_086" #Example: "3_0_1_055"
$global:mathtools_url = "http://movemen.com/files/downloads/mtv3/086" #do not add trailing slash, example: "http://movemen.com/files/downloads/mtv3/055"


########################################################
########################################################



########################################################
########################################################
#
# Functions
########################################################
########################################################

######## FUNCTION ####################
function downloadMathToolsCC($YYYY)
{
  Write-Host "DEBUG: Downloading MathTools for InDesign CC Server" $YYYY
  $mathtools = "MathToolsEESrv-$mathtools_version-CC-$YYYY-WIN64.zip"
  $url = "$mathtools_url/$mathtools"
  Write-Host "DEBUG: MathTools URL is $url"
  $global:output_dir = "$PSScriptRoot\staging\mathtools\$YYYY"
  $output = "$output_dir\$mathtools"
  $start_time = Get-Date

  New-Item -ItemType directory -Path $output_dir -Force
   Write-Output "DEBUG: URL for download is $url."
  Invoke-WebRequest -Uri $url -OutFile $output
  Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"


    $verifyDownload = "$output_dir\MathToolsEESrv-$mathtools_version-CC-$YYYY-WIN64.zip"
    Write-Output "DEBUG: Check if $verifyDownload is here."
    if (Test-Path $verifyDownload -PathType leaf)
        {
             Write-Warning "DEBUG: $verifyDownload exists."
        }
        else
        {
            Write-Warning "FAILURE: $verifyDownload MISSING."
            [Environment]::Exit(1)

        }


}

######## FUNCTION ####################
function downloadMathTools($YYYY)
{
  Write-Host "DEBUG: Downloading MathTools for InDesign Server" $YYYY
  $mathtools = "MathToolsEESrv-$mathtools_version-$YYYY-WIN64.zip"
  $url = "$mathtools_url/$mathtools"
  Write-Host "DEBUG: MathTools URL is $url"
  $global:output_dir = "$PSScriptRoot\staging\mathtools\$YYYY"
  $output = "$output_dir\$mathtools"
  $start_time = Get-Date

  New-Item -ItemType directory -Path $output_dir -Force
   Write-Output "DEBUG: URL for download is $url."
  Invoke-WebRequest -Uri $url -OutFile $output
  Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    $verifyDownload = "$output_dir\MathToolsEESrv-$mathtools_version-$YYYY-WIN64.zip"
    Write-Output "DEBUG: Check if $verifyDownload is here."
    if (Test-Path $verifyDownload -PathType leaf)
        {
             Write-Warning "DEBUG: $verifyDownload exists."
        }
        else
        {
            Write-Warning "FAILURE: $verifyDownload MISSING."
            [Environment]::Exit(1)

        }

}

function downloadMathTools2021($YYYY)
{
  Write-Host "DEBUG: Downloading MathTools for InDesign Server" $YYYY
  $mathtools = "MathToolsEESrv-$mathtools_version-2021_0-WIN64.zip" #temporary override for anomaly in URLs.
  $url = "$mathtools_url/$mathtools"
  Write-Host "DEBUG: MathTools URL is $url"
  $global:output_dir = "$PSScriptRoot\staging\mathtools\$YYYY"
  $output = "$output_dir\$mathtools"
  $start_time = Get-Date

  New-Item -ItemType directory -Path $output_dir -Force
   Write-Output "DEBUG: URL for download is $url."
  Invoke-WebRequest -Uri $url -OutFile $output
  Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    $verifyDownload = "$output_dir\MathToolsEESrv-$mathtools_version-2021_0-WIN64.zip"  #temporary override for anomaly in URLs.
    Write-Output "DEBUG: Check if $verifyDownload is here."
    if (Test-Path $verifyDownload -PathType leaf)
        {
             Write-Warning "DEBUG: $verifyDownload exists."
        }
        else
        {
            Write-Warning "FAILURE: $verifyDownload MISSING."
            [Environment]::Exit(1)

        }

}

######## FUNCTION ####################
function backupMathToolsLicense
{
  Write-Host "DEBUG: Copying license file from:" $idsLocation
  New-Item -ItemType directory -Path $output_dir\lic -Force
  Copy-Item $idsLocation\Plug-Ins\movemen\lic\*.lic -Destination $output_dir\lic -Force -ErrorAction SilentlyContinue

}

######## FUNCTION ####################
function updateMathToolsCC($YYYY)
{
    #call function
    Write-Host "DEBUG: This is updateMathTools for IDS $YYYY"
    Write-Host "DEBUG: Stopping InDesign CC $YYYY"
    Stop-Service -Name "InDesignServerService x64"
    Get-Process "InDesign*" | Stop-Process -Force
    #call function
    Write-Host "DEBUG: Backing up MathTools License $YYYY"
    backupMathToolsLicense

    #main body
    #remove old MathTools
    Remove-Item $idsLocation\Plug-Ins\movemen -Force -Recurse -ErrorAction SilentlyContinue

    #production
    Write-Host "DEBUG: Working with MathToolsEESrv-$mathtools_version-CC-$YYYY-WIN64.zip"
    Microsoft.PowerShell.Archive\Expand-Archive -Path $output_dir\MathToolsEESrv-$mathtools_version-CC-$YYYY-WIN64.zip -DestinationPath $idsLocation\Plug-Ins -Force
    Copy-Item  $output_dir\lic\*.lic -Destination $idsLocation\Plug-Ins\movemen\lic -Force  -ErrorAction SilentlyContinue

    #call function
    Write-Host "DEBUG: Starting InDesign CC $YYYY"
    Start-Service -Name "InDesignServerService x64"

}

function updateMathTools($YYYY)
{
    #call function
    Write-Host "DEBUG: This is updateMathTools2020 for IDS $YYYY"
    Write-Host "DEBUG: Stopping InDesign CC $YYYY"
    Stop-Service -Name "InDesignServerService x64"
    Get-Process "InDesign*" | Stop-Process -Force
    #call function
    Write-Host "DEBUG: Backing up MathTools License $YYYY"
    backupMathToolsLicense

    #main body
    #remove old MathTools
    Remove-Item $idsLocation\Plug-Ins\movemen -Force -Recurse -ErrorAction SilentlyContinue

    #production
    Write-Host "DEBUG: Working with MathToolsEESrv-$mathtools_version-$YYYY-WIN64.zip"
    Microsoft.PowerShell.Archive\Expand-Archive -Path $output_dir\MathToolsEESrv-$mathtools_version-$YYYY-WIN64.zip -DestinationPath $idsLocation\Plug-Ins -Force
    Copy-Item  $output_dir\lic\*.lic -Destination $idsLocation\Plug-Ins\movemen\lic -Force  -ErrorAction SilentlyContinue

    #call function
    Write-Host "DEBUG: Starting InDesign CC $YYYY"
    Start-Service -Name "InDesignServerService x64"

}

function updateMathTools2021($YYYY)
{
    #call function
    Write-Host "DEBUG: This is updateMathTools for IDS $YYYY"
    Write-Host "DEBUG: Stopping InDesign CC $YYYY"
    Stop-Service -Name "InDesignServerService x64"
    Get-Process "InDesign*" | Stop-Process -Force
    #call function
    Write-Host "DEBUG: Backing up MathTools License $YYYY"
    backupMathToolsLicense

    #main body
    #remove old MathTools
    Remove-Item $idsLocation\Plug-Ins\movemen -Force -Recurse -ErrorAction SilentlyContinue

    #production
    Write-Host "DEBUG: Working with MathToolsEESrv-$mathtools_version-2021_0-WIN64.zip" #temporary override for name anomaly
    Microsoft.PowerShell.Archive\Expand-Archive -Path $output_dir\MathToolsEESrv-$mathtools_version-2021_0-WIN64.zip -DestinationPath $idsLocation\Plug-Ins -Force #temporary override for name anomaly
    Copy-Item  $output_dir\lic\*.lic -Destination $idsLocation\Plug-Ins\movemen\lic -Force  -ErrorAction SilentlyContinue

    #call function
    Write-Host "DEBUG: Starting InDesign CC $YYYY"
    Start-Service -Name "InDesignServerService x64"

}

######## FUNCTION ####################
function detectMathTools
{

#If detected, proceed to update.

If (Test-Path $idsLocation\Plug-Ins\movemen)
    {
        Write-Host "DEBUG: WARN! MathTools was found."
    }

Else
    {
        Write-Host "DEBUG: OK! MathTools was not found."

     }

}


################################################################################################################
################################################################################################################
#
# main body
#
################################################################################################################
################################################################################################################

  $idsregkey = 'HKLM:\SYSTEM\CurrentControlSet\Services\InDesignServerService x64'
  If (Test-Path $idsregkey) {
    Write-Host "DEBUG: OK! Adobe InDesign Server Service was found."
    $regkey = Get-ItemProperty -Path $idsregkey -Name "ImagePath"
    $value = $regkey.ImagePath
    $path = $value.Replace("`"","")
    $folder = Split-Path -Path $path
    $global:idsMajorVersion = (Get-Item "$folder\InDesignServer.exe").VersionInfo.FileMajorPart
    $global:idsLocation = $folder
    Write-Host "DEBUG: Adobe InDesing Server is installed in $idsLocation"

    #check to see if MathTools is present. If not, the upgrade needs to abort.
    detectMathTools

    #if MathTools is detected, we can continue to download the latest version

    Switch ($idsMajorVersion)
      {
          12 {$idsYYYY = "2017"; "DEBUG: Adobe InDesign Server CC $idsYYYY"; downloadMathToolsCC "$idsYYYY"; updateMathToolsCC "$idsYYYY"}
          13 {$idsYYYY = "2018"; "DEBUG: Adobe InDesign Server CC $idsYYYY"; downloadMathToolsCC "$idsYYYY"; updateMathToolsCC "$idsYYYY"}
          14 {$idsYYYY = "2019"; "DEBUG: Adobe InDesign Server CC $idsYYYY"; downloadMathToolsCC "$idsYYYY"; updateMathToolsCC "$idsYYYY"}
          15 {$idsYYYY = "2020"; "DEBUG: Adobe InDesign Server $idsYYYY"; downloadMathTools "$idsYYYY"; updateMathTools "$idsYYYY"}
          16 {$idsYYYY = "2021"; "DEBUG: Adobe InDesign Server $idsYYYY"; downloadMathTools2021 "$idsYYYY"; updateMathTools2021 "$idsYYYY"}
      }


  }

  ELSE {
    Write-Host "DEBUG: WARN! Adobe InDesign Server Service was not found."
    Write-Host "DEBUG: OK! Exiting."
    exit 0

  }


   Write-Host "DEBUG: Arrived at the end!"


Stop-Transcript
