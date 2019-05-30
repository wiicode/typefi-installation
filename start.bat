set a=%~dp0
set b=typefi_installer.ps1
set script=%a%%b%
echo %script%
powershell %script%