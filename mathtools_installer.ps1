$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:logfile = "$PSScriptRoot\logs\mathtools_install_output.txt"
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
$global:mathtools_version = "3_0_1_058" #Example: "3_0_1_058"
$global:mathtools_url = "http://movemen.com/files/downloads/mtv3/058" #do not add trailing slash, example: "http://movemen.com/files/downloads/mtv3/058"
$idsVersions = @("$ids2019","$ids2018","$ids2017") #example, "$ids2019","$ids2018","$ids2017"
#

######## FUNCTION ####################
function downloadMathTools($YYYY)
{
  Write-Host "DEBUG: Downloading MathTools for InDesign CC" $YYYY
  $mathtools = "MathToolsEESrv-$mathtools_version-CC-$YYYY-WIN64.zip"
  $url = "$mathtools_url/$mathtools"
  $global:output_dir = "$PSScriptRoot\staging\mathtools\$YYYY\"
  $output = "$output_dir\$mathtools"
  $start_time = Get-Date

  New-Item -ItemType directory -Path $output_dir -Force
  Invoke-WebRequest -Uri $url -OutFile $output
  Write-Output "DEBUG: Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

}

######## FUNCTION ####################
function installMathTools($YYYY)
{
  #call function
    Write-Host "DEBUG: Stopping InDesign CC $YYYY"
    Stop-Service -Name "InDesignServerService x64"

  #call function

    #main body

    #prepare new MathTools
    #debug
    #New-Item -ItemType directory -Path $output_dir\debug -Force
    #Expand-Archive -Path $output_dir\MathToolsEESrv-3_0_1_055-CC-$YYYY-WIN64.zip -DestinationPath $output_dir\debug -Force
    #Copy-Item $output_dir\lic\*.lic -Destination $output_dir\debug\movemen\lic -Force

    #production
    Microsoft.PowerShell.Archive\Expand-Archive -Path $output_dir\MathToolsEESrv-$mathtools_version-CC-$YYYY-WIN64.zip -DestinationPath $ids_path_dir\Plug-Ins -Force
    #if a license exists (maybe this is a reinstall?) then copy it in.
    If (Test-Path $output_dir\lic\mt.MathToolsV2.lic)
        {

            Write-Host "Previous license found. Restoring."
            Copy-Item  $output_dir\lic\*.lic -Destination $ids_path_dir\Plug-Ins\movemen\lic -Force
        }

    Else
        {

            Write-Host "Did not find existing MathTools Licenses."

         }


  #call function
    Write-Host "DEBUG: Starting InDesign CC $YYYY"
    Start-Service -Name "InDesignServerService x64"


}

######## FUNCTION ####################
function detectMathTools($YYYY)
{

#If detected, proceed to update.

If (Test-Path $ids_path_dir\Plug-Ins\movemen)
    {

        Write-Host "MathTools was found.  Skipping installation."
    }

Else
    {

        Write-Host "Did not find MathTools on this attempt. Proceeding with installation."
        installMathTools "$YYYY"

     }



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

            downloadMathTools "$idsYYYY"

            detectMathTools "$idsYYYY"



        }

    Else
        {

            Write-Host "Did not find InDesign on this attempt."

         }

#end of loop
 }

Stop-Transcript
