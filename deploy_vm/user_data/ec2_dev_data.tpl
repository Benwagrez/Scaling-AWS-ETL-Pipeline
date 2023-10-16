<powershell>
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Install-Module Posh-Git -Force
Install-Module PSWindowsUpdate -Force
# Install-Module PSScheduledJob -Force

Import-Module PSWindowsUpdate 
Import-Module PSScheduledJob
$dir = $env:TEMP;
Set-Location $dir

$urlRStudio = "https://download1.rstudio.org/electron/windows/RStudio-2023.09.0-463.exe"
$outputRStudio = "$dir\RStudio-2023.09.0-463.exe"

$wcRStudio = New-Object System.Net.WebClient
$wcRStudio.DownloadFile($urlRStudio, $outputRStudio) # $PSScriptRoot 

$urlR = "https://cran.rstudio.com/bin/windows/base/R-4.3.1-win.exe"
$outputR = "$dir\R-4.3.1-win.exe"
$wcR = New-Object System.Net.WebClient
$wcR.DownloadFile($urlR, $outputR)

Start-Process -Wait -FilePath $outputRStudio -ArgumentList "/S" -PassThru
Start-Process -Wait -FilePath $outputR -ArgumentList "/SILENT" -PassThru

$gitconfig = @"
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Components=ext,ext\shellhere,ext\guihere,gitlfs,assoc,autoupdate
Tasks=
EditorOption=VIM
CustomEditorPath=
PathOption=Cmd
SSHOption=OpenSSH
TortoiseOption=false
CURLOption=WinSSL
CRLFOption=LFOnly
BashTerminalOption=ConHost
PerformanceTweaksFSCache=Enabled
UseCredentialManager=Enabled
EnableSymlinks=Disabled
EnableBuiltinInteractiveAdd=Disabled
"@

New-Item gitconfig.inf -ItemType file -Value $gitconfig

# get latest download url for git-for-windows 64-bit exe
$git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$asset = Invoke-RestMethod -Method Get -Uri $git_url | % assets | where name -like "*64-bit.exe"

# download installer
$installer = "$env:temp\$($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer

# run installer
$git_install_inf = "gitconfig.inf"
$install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
Start-Process -FilePath $installer -ArgumentList $install_args -Wait

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

</powershell>