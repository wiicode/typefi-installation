<#
Rolls back InDesignServerService.exe to version 14.0.0.130.
#>
$PSVersionTable.PSVersion
$ErrorActionPreference = "SilentlyContinue"
$global:logfile = "c:\ops\logs\$currentfile.txt"
Start-Transcript -path $logfile -Append
Write-Host "Alpha"
#check if InDesign CC version exists, and figure out the installation directory
#2019, Registry::HKEY_CLASSES_ROOT\CLSID\{CE7A178C-C019-4749-8FA5-45A847E01EAF}\LocalServer32
#2018, Registry::HKEY_CLASSES_ROOT\CLSID\{74812DB7-FA97-43E0-97F5-87D1E47B76E4}\LocalServer32
#2017, Registry::HKEY_CLASSES_ROOT\CLSID\{C62D9F67-2815-4C5D-9754-5CEAA121CDD8}\LocalServer32
#
#Figure out if InDesign is installed and do stuff!
## Edit this as needed
$ids2019 = "Registry::HKEY_CLASSES_ROOT\CLSID\{CE7A178C-C019-4749-8FA5-45A847E01EAF}\LocalServer32"
$ids2018 = "Registry::HKEY_CLASSES_ROOT\CLSID\{74812DB7-FA97-43E0-97F5-87D1E47B76E4}\LocalServer32"
$ids2017 = "Registry::HKEY_CLASSES_ROOT\CLSID\{C62D9F67-2815-4C5D-9754-5CEAA121CDD8}\LocalServer32"
#
## Edit these as needed ###
$global:hotfix_url = "https://www.dropbox.com/s/niryvihtgi859a4/InDesignServerService.zip?dl=1"
$global:hotfix_destination_folder = ""
$idsVersions = @("$ids2019") # this fix is only for 2019
#


######## FUNCTION ####################
function downloadHotfix($YYYY)
{
  Write-Host "DEBUG: Downloading hotfix for InDesign CC" $YYYY
  $hotfix = "InDesignServerService.zip"
  $url = "$hotfix_url"
  $global:output_dir = "c:\ops\temp\hotfixservice\$YYYY-zip\"
  $output = "$output_dir\$hotfix"
  $start_time = Get-Date

  New-Item -ItemType directory -Path $output_dir -Force
  Invoke-WebRequest -Uri $url -OutFile $output
  Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

}


######## FUNCTION ####################
function installhotfix($YYYY)
{
  #call function
    Write-Host "DEBUG: Stopping InDesign CC $YYYY"
    Stop-Service -Name "InDesignServerService x64"
    Get-Process "InDesign*" | Stop-Process -Force

  #call function

    #main body
    #production
    Microsoft.PowerShell.Archive\Expand-Archive -Path $output_dir\InDesignServerService.zip -DestinationPath "c:\ops\temp\hotfixservice\$YYYY-extracted" -Force
    #if a license exists (maybe this is a reinstall?) then copy it in.

    Copy-Item c:\ops\temp\hotfixservice\$YYYY-extracted\*.* -Destination "$ids_path_dir" -verbose -Force


    #call function
    Write-Host "DEBUG: Starting InDesign CC $YYYY"
    Start-Service -Name "InDesignServerService x64"


}



#
#
#
# main body
#
#
#
#start of loop

 foreach ($idsVer in $idsVersions) {
   "$idsVer = " + $idsVer.length
    Write-Host "Trying InDesign:" $idsVer

    If (Test-Path $idsVer)
        {
            Write-Host "$idsFound"
            $ids_path_exe = (Get-ItemProperty -LiteralPath "$idsVer").'(default)'
            Write-Host "DEBUG:" $ids_path_exe
            $global:ids_path_dir = Split-Path -Path $ids_path_exe
            Write-Host "DEBUG:" $ids_path_dir
            $global:idsYYYY = $ids_path_dir.substring($ids_path_dir.length - 4)
            Write-Host "DEBUG:" $idsYYYY

            downloadHotfix "$idsYYYY"
            installhotfix "$idsYYYY"




        }

    Else
        {

            Write-Host "Did not find InDesign on this attempt."

         }

#end of loop
 }

Stop-Transcript
