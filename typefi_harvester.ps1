<#
-----
Typefi Harvester version 0.1.3
This script will collect Typefi installation information and output it to a file.
It should run on the Typefi Server installation and any InDesign Engines being used.

This script collects the following information into a single text file.
-----
#>

$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:currentfile = $MyInvocation.MyCommand.Path
$global:logfile = "$currentfile.txt"
$global:typefi = "c:\ProgramData\Typefi"
<#
-----
Start Logging
-----
#>
Start-Transcript -path $logfile
Write-Host "-.. . -... ..- --.DEBUG Callsign: ALPHA"
Write-Host "-.. . -... ..- --.DEBUG Logfile:" $logfile
<#
-----
Set Global  Variables
-----
#>



<#
-----
TYPEFI Server
Check for
- Presence of known services
- Presence of ProgramData independently of services in case InDesign was used
- Make an API call regardless of the other two just to see what we get.
-----
#>


<#
-----
INDESIGN SERVER
-----
#>

$ids2019 = "Registry::HKEY_CLASSES_ROOT\CLSID\{CE7A178C-C019-4749-8FA5-45A847E01EAF}\LocalServer32"
$ids2018 = "Registry::HKEY_CLASSES_ROOT\CLSID\{74812DB7-FA97-43E0-97F5-87D1E47B76E4}\LocalServer32"
$ids2017 = "Registry::HKEY_CLASSES_ROOT\CLSID\{C62D9F67-2815-4C5D-9754-5CEAA121CDD8}\LocalServer32"
$ids2015 = "Registry::HKEY_CLASSES_ROOT\CLSID\{AE4167A3-35E4-4B93-A620-AD088ABEB207}\LocalServer32"
$idsVersions = @("$ids2019","$ids2018","$ids2017","$ids2015") #example, "$ids2019","$ids2018","$ids2017"


foreach ($idsVer in $idsVersions) {
  "$idsVer = " + $idsVer.length


   If (Test-Path $idsVer)
       {

           $ids_path_exe = (Get-ItemProperty -LiteralPath "$idsVer").'(default)'
           $global:ids_path_dir = Split-Path -Path $ids_path_exe
           $global:idsYYYY = $ids_path_dir.substring($ids_path_dir.length - 4)
           $ids_exe_version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$ids_path_exe").FileVersion

           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " ---------------------               --------------------- "
           Write-Host " ---------------------               --------------------- "
           Write-Host " --------------------- SECTION START --------------------- "
           Write-Host " ---------------------               --------------------- "
           Write-Host " ---------------------               --------------------- "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host "InDesign Collector: "
           Write-Host "-t-> InDesign Server Release:" $idsYYYY
           Write-Host "-t-> InDesign Server Version:" $ids_exe_version
           Write-Host "-t-> InDesign Server Directory:" $ids_path_dir
           Write-Host "-t-> InDesign Server Fonts store is:" $ids_fontsize
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           $fonts = "$ids_path_dir\Fonts"
           If (Test-Path $fonts) {
              #Get size of Adobe Font folder, manifest retrieval is not reliable
              $ids_fontsize = "{0:N2} MB" -f ((Get-ChildItem $ids_path_dir\Fonts -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
              Write-Host "-t-> InDesign Server Fonts are:" $ids_fontsize
              Get-ChildItem $ids_path_dir\Fonts -File | Format-Table Name, LastWriteTime
            }
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host "-t-> InDesign Server Plugins are:"
           Get-ChildItem $ids_path_dir\Plug-Ins -Dir | Format-Table Name, LastWriteTime
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host "-t-> InDesign Server Scripts are:"
           Get-ChildItem $ids_path_dir\Scripts -File | Format-Table Name, LastWriteTime
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host "-t-> InDesign Server Presets are:"
           Get-ChildItem "$ids_path_dir\Resources\Adobe PDF\settings\mul" -File | Format-Table Name, LastWriteTime
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host "-t-> InDesign Server Services include:"
           Get-WmiObject Win32_Service -Filter "name='InDesignServerService x64'" | Format-Table Name, DisplayName, State, StartMode, StartName
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "
           Write-Host "-t-> InDesign Server Processes include:"
           #Get-Process -Name *indesign* | Format-Table -Property Path,Name,Id,Company
           Get-Process -Name *indesign* | Format-Table -Property Name,Id
           Write-Host " "
           Write-Host " ---------------------               --------------------- "
           Write-Host " "

           $idsLicDirectory = "C:\ProgramData\regid.1986-12.com.adobe"
           If (Test-Path $idsLicDirectory)
               {
                 $adobeIdsLicenseFiles = @(Get-ChildItem -Path $idsLicDirectory\*.swidtag)
                 foreach ($idsLicFile in $adobeIdsLicenseFiles)
                 {
                   Write-Host "-t-> InDesign License Readout:" $idsLicFile
                   Write-Host " "
                   Write-Host "*****************************************************************"
                   Write-Host "*********************** FILE OUTPUT *****************************"
                   Write-Host "*****************************************************************"
                   Write-Host " "
                   Get-Content $idsLicFile | select -Last 7
                   Write-Host " "
                   Write-Host "*****************************************************************"
                   Write-Host "************************** END **********************************"
                   Write-Host "*****************************************************************"
                   Write-Host " "
                 }
               }

           Else
               {

                   Write-Host "-.. . -... ..- --.DEBUG No .swidtag"

                }



            Write-Host " "
            Write-Host " ---------------------             --------------------- "
            Write-Host " ---------------------             --------------------- "
            Write-Host " ---------------------             --------------------- "
            Write-Host " --------------------- SECTION END --------------------- "
            Write-Host " ---------------------             --------------------- "
            Write-Host " ---------------------             --------------------- "
            Write-Host " ---------------------             --------------------- "
            Write-Host " "
       }

   Else
       {

          Write-Host "-.. . -... ..- --.DEBUG InDesign Server search complete."

        }

#end of loop
}



<#
-----
TYPEFI SERVER
-----
#>


Write-Host " "
Write-Host " ---------------------               --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " --------------------- SECTION START --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " ---------------------               --------------------- "
Write-Host " "
Write-Host " ---------------------               --------------------- "
Write-Host " "
Write-Host "-t-> Typefi Installations include:"
#SLOWLOOKUP
Get-WmiObject -Class Win32_Product -Filter "Name LIKE 'Typefi%'" | Format-Table -Property Name,Version
Write-Host " "

If (Test-Path $typefi)
    {
        #Suepruser harvest.
        $fsu_path = "$typefi\Superuser.properties"
        $fsu_values = Get-Content $fsu_path | Out-String | ConvertFrom-StringData
        Write-Host " ---------------------               --------------------- "
        Write-Host " "
        If ($fsu_values.SUPERUSER_PASSWORD -eq 92668751)
          {
              Write-Host "-t-> Superuser password has NOT been changed! // DEBUG:" $fsu_values.SUPERUSER_PASSWORD
          }
        Else
          {
              Write-Host "-t-> Superuser password has been changed, you are doing grrreat!"
          }
        Write-Host " "

        #Filestore harvest.
        $fs_path = "$typefi\Filestore.properties"
        $fs_values = Get-Content $fs_path | Out-String | ConvertFrom-StringData
        Write-Host " ---------------------               --------------------- "
        Write-Host " "
        Write-Host "-t-> File Store is located at:" $fs_values.FILESTORE_LOC
        #SOWLOOKUP
        $fs_size = "{0:N2} MB" -f ((Get-ChildItem $fs_values.FILESTORE_LOC -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
        Write-Host "-t-> File Store size is:" $fs_size
        Write-Host " "

        #LDAP harvest.
        $ldap_path = "$typefi\Ldap.properties"
        $ldap_values = Get-Content $ldap_path | Out-String | ConvertFrom-StringData
        Write-Host " ---------------------               --------------------- "
        Write-Host " "
        Write-Host "-t-> LDAP is in use:" $ldap_values.LDAP_IN_USE
        Write-Host " "

        #Tomcat harvest.
        $typefi_reg = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Typefi\Server8"
        $typefi_reg_32bit = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Typefi\Server8"
        If (Test-Path $typefi_reg)
          {

            $tomcat_path = (Get-ItemProperty -LiteralPath "$typefi_reg").'Path'
            $jre = & cmd /c "$tomcat_path\JRE\bin\java.exe -version 2>&1"
            $java = & cmd /c "java -version 2>&1"

            Write-Host " ---------------------               --------------------- "
            Write-Host " "
            Write-Host "-t-> Typefi Tomcat is installed to:" $tomcat_path
            Write-Host "-t-> Installed JRE is:" $jre
            Write-Host "-t-> Installed system JAVA is:" $java
            Write-Host "-t-> Typefi Plugins installed are:"
            Get-ChildItem $tomcat_path\Server\webapps -File | Format-Table Name, LastWriteTime
            Write-Host " "

          }
        Else
          {

            $tomcat_path = (Get-ItemProperty -LiteralPath "$typefi_reg_32bit").'Path'
            $jre = & cmd /c "$tomcat_path\JRE\bin\java.exe -version 2>&1"
            $java = & cmd /c "java -version 2>&1"

            Write-Host " ---------------------               --------------------- "
            Write-Host " "
            Write-Host "-t-> Typefi Tomcat is installed to:" $tomcat_path
            Write-Host "-t-> Installed JRE is:" $jre
            Write-Host "-t-> Installed system JAVA is:" $java
            Write-Host "-t-> Typefi Plugins installed are:"
            Get-ChildItem $tomcat_path\Server\webapps -File | Format-Table Name, LastWriteTime
            Write-Host " "

          }


        #license harvest.
        Write-Host " "
        Write-Host " ---------------------               --------------------- "
        Write-Host " "
        Write-Host "-t-> Typefi Licenses:"
        Write-Host " "
        Write-Host "*****************************************************************"
        Write-Host "*********************** FILE OUTPUT *****************************"
        Write-Host "*****************************************************************"
        Write-Host " "
        Get-Content $typefi\licenses.json
        Write-Host " "
        Write-Host "*****************************************************************"
        Write-Host "************************** END **********************************"
        Write-Host "*****************************************************************"
        Write-Host " "

        #Log harvest.
        Write-Host " "
        Write-Host " ---------------------               --------------------- "
        Write-Host " "
        Write-Host "-t-> Typefi TPSS Log's last few lines:"
        Write-Host " "
        Write-Host "*****************************************************************"
        Write-Host "*********************** FILE OUTPUT *****************************"
        Write-Host "*****************************************************************"
        Write-Host " "
        Get-Content $typefi\TPSS.log | select -Last 25
        Write-Host " "
        Write-Host "*****************************************************************"
        Write-Host "************************** END **********************************"
        Write-Host "*****************************************************************"
        Write-Host " "



    }

    Else
        {

           Write-Host "-.. . -... ..- --.DEBUG InDesign Server search complete."

         }

Write-Host " "
Write-Host " ---------------------             --------------------- "
Write-Host " ---------------------             --------------------- "
Write-Host " ---------------------             --------------------- "
Write-Host " --------------------- SECTION END --------------------- "
Write-Host " ---------------------             --------------------- "
Write-Host " ---------------------             --------------------- "
Write-Host " ---------------------             --------------------- "
Write-Host " "

<#
-----
Stop Logging
-----
#>
Stop-Transcript
