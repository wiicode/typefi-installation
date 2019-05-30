<#
-----
Typefi Plugin Installation and Update script, version 1.0.0
This script will install or update all Typefi Plugins.
Current Version: requires manual selection of plugins.
Future Plans: read selection from a Typefi 8.5 compatible license file.

Functions
- Check for prior runs of this script.
- Detect installation type
- Validate license
- Stage Plugins
- Figure out Tomcat Directory
- List currently installed plugins.
- Offer a menu with choices to select which plugins are installed. One option is to "Run with previous settings."
- Build a list of plugins to install.
- Stop Typefi Tomcat
- Clear out all WAR files and Plugins
- Start Typefi Tomcat



This script collects the following information into a single text file.
-----
#>

$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:workingdirectory =
$global:currentfile = $MyInvocation.MyCommand.Path
$global:logfile = "$currentfile.txt"
$global:typefi = "c:\ProgramData\Typefi"
$global:debug = "C:\PAYLOAD\Installigence"
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
FUNCTIONS
#>

    <# function name debug - start #>
    #write-FunctionName
    <# function name debug# - end #>

Function write-FunctionName
{
    write-host ("-t-> The name of this function is: {0} " -f $MyInvocation.MyCommand)
}

function displayApps
{
    <# function name debug - start #>
    write-FunctionName
    <# function name debug# - end #>
    Write-Host "-t-> Typefi Installations include:"
    Get-WmiObject -Class Win32_Product -Filter "Name LIKE 'Typefi%'" | Format-Table -Property Name,Version

}

function readPlugins
{
     <# function name debug - start #>
    write-FunctionName
    <# function name debug# - end #>
    Write-Host "-t-> Typefi Plugins located in:" $TYPEFI_PLUGINS

}

function harvest {

    <# function name debug - start #>
    write-FunctionName
    <# function name debug# - end #>

    If (Test-Path $typefi)
    {
            #license harvest.
            $lic_path = "$typefi\licenses.json"
            $lic_values = Get-Content -RAW -Path $lic_path | ConvertFrom-JSON
            $global:installationCode = $lic_values.installationCode
            Write-Host "-t-> The Typefi Installation ID validation detected:" $installationCode

            #Tomcat harvest.
            $typefi_reg = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Typefi\Server8"
            $typefi_reg_32bit = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Typefi\Server8"
            If (Test-Path $typefi_reg)
                {
                    Write-Host "-t-> The Typefi 64bit detected:"
                    $tomcat_path = (Get-ItemProperty -LiteralPath "$typefi_reg").'Path'
                    $global:TYPEFI_PLUGINS = "$tomcat_path\Server\webapps"
                    displayApps
                    readPlugins

                }
            ElseIf (Test-Path $typefi_reg_32bit)
                {
                    Write-Host "-t-> The Typefi 32bit detected:"
                    $tomcat_path = (Get-ItemProperty -LiteralPath "$typefi_reg_32bit").'Path'
                    $global:TYPEFI_PLUGINS = "$tomcat_path\Server\webapps"
                    displayApps
                    readPlugins
                }

             ElseIf (Test-Path $debug)
                {
                    Write-Host "-t-> The Typefi DEBUG location detected:"
                    $global:TYPEFI_PLUGINS = "$debug\Server\webapps"
                    displayApps
                    readPlugins
                }


            Else
                {

                    Write-Host "-t-> WARNING: Typefi installation not supported by this script."
                }



        }

        Else
            {

            Write-Host "-t-> WARNING: Typefi installation not found, unable to continue. "

            }



}

function servicewaitstop($srvName) {

    $maxRepeat = 100
    $status = "Running" # change to Stopped if you want to wait for services to start

    do 
        {
            $count = (Get-Service $srvName | ? {$_.status -eq $status}).count
            $maxRepeat--
            sleep -Milliseconds 600
        } 
    
    until ($count -eq 0 -or $maxRepeat -eq 0)

}

function servicewaitstart($srvName) {

    $maxRepeat = 100
    $status = "Stopped" # change to Stopped if you want to wait for services to start

    do 
        {
            $count = (Get-Service $srvName | ? {$_.status -eq $status}).count
            $maxRepeat--
            sleep -Milliseconds 600
        } 
    
    until ($count -eq 0 -or $maxRepeat -eq 0)

}


function sharedcode {

    <# function name debug - start #>
    write-FunctionName
    <# function name debug# - end #>


    #########################################
    #
    # Cleanup plugins and folders
    #
    #########################################


    #Get-ChildItem $TYPEFI_PLUGINS -Force -Filter typefi-plugin* | Remove-Item -Recurse
    #Get-ChildItem $TYPEFI_PLUGINS -Force -Filter typefi-plugin*.war | Remove-Item -Recurse



}


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
TYPEFI SERVER
-----
#>

<# the bug call to collect info #>
harvest
<# the bug call to collect info #>



<#
-----
Stop Logging
-----
#>
Stop-Transcript
