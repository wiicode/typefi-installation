<#
-----
Typefi C drive cleanup script.  Custom made to our needs but can run on any Windows Server.
Removes stale log files, including that stored in Typefi installations
-----
#>

$PSVersionTable.PSVersion
$ErrorActionPreference = "Continue"
$global:logfile = "c:\ops\logs\typefi_file_cleanup.txt"
$global:typefi = "c:\ProgramData\Typefi"
$global:typefi_tomcat_env_test = Test-Path Env:\tomcat_path
Write-Host "-.. . -... ..- --.DEBUG typefi_tomcat_env_test: $typefi_tomcat_env_test"

<#
-----
Start Logging
-----
#>
Start-Transcript -Path $logfile
Write-Host "-.. . -... ..- --.DEBUG Callsign: ALPHA"
Write-Host "-.. . -... ..- --.DEBUG Logfile:" $logfile

<#
-----
Start cleanup of common C drive paths
-----
#>

function cleanCdrive
{

  Write-Host "-.. . -... ..- --.DEBUG : Default deletions"
  $folders = @("C:\Windows\Temp\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*", "C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files\*", "C:\Windows\SoftwareDistribution\Download", "C:\Windows\System32\FNTCACHE.DAT", "C:\Windows\Logs\*")
  foreach ($folder in $folders) {Remove-Item $folder -force -recurse  -verbose -ErrorAction SilentlyContinue}

} #END FUNCTION

<#
-----
Start cleanup of Typefi common items in Typefi Workgroup.
-----
#>

function cleanTypefi
{
  Write-Host "-.. . -... ..- --.DEBUG : Typefi Sequence start"
        If (Test-Path $typefi)
          {

            #Tomcat detect.
            Write-Host "-.. . -... ..- --.DEBUG : Collecting install paths"
            $typefi_reg = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Typefi\Server8"
            $typefi_reg_32bit = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Typefi\Server8"
            If (Test-Path $typefi_reg)
              {
                Write-Host "-.. . -... ..- --.DEBUG : Commence Typefi Workgroup 64bit Cleanup"
                Write-Host "-.. . -... ..- --.DEBUG : CLEANING FILES IN $tomcat_path"
                $tomcat_path = (Get-ItemProperty -LiteralPath "$typefi_reg").'Path'
                $folders = @("$tomcat_path\temp\*", "$tomcat_path\logs\*", "$tomcat_path\Server\temp\*", "$tomcat_path\Server\logs\*")
                foreach ($folder in $folders) {Remove-Item $folder -force -recurse -verbose -ErrorAction SilentlyContinue}

            }

          ElseIf (Test-Path $typefi_reg_32bit)
            {
              Write-Host "-.. . -... ..- --.DEBUG : Commence Typefi Workgroup 32bit Cleanup"
              Write-Host "-.. . -... ..- --.DEBUG : CLEANING FILES IN $tomcat_path"
              $tomcat_path = (Get-ItemProperty -LiteralPath "$typefi_reg_32bit").'Path'
              $folders = @("$tomcat_path\temp\*", "$tomcat_path\logs\*", "$tomcat_path\Server\temp\*", "$tomcat_path\Server\logs\*")
              foreach ($folder in $folders) {Remove-Item $folder -force -recurse -verbose -ErrorAction SilentlyContinue}

            }

          ElseIf ($typefi_tomcat_env_test -eq $True)
            {
              Write-Host "-.. . -... ..- --.DEBUG : Commence Typefi Cloud cleanup."
              Write-Host "-.. . -... ..- --.DEBUG : CLEANING FILES IN $tomcat_path"
              $typefi_tomcat_path = (get-item env:tomcat_path).Value
              $folders = @("$typefi_tomcat_path\temp\*", "$typefi_tomcat_path\logs\*", "$tomcat_path\Server\temp\*", "$tomcat_path\Server\logs\*")
              foreach ($folder in $folders) {Remove-Item $folder -force -recurse -verbose -ErrorAction SilentlyContinue}

            }

          Else
            {

              #do nothing

            }

      }



} #End Function

<#
-----
MAIN CODE
-----
#>


#Call Functions
cleanCdrive
cleanTypefi



Write-Host "-.. . -... ..- --.DEBUG : Arrived at the end!"
Stop-Transcript
exit 0
