Start-Transcript -Path "$(get-date -Format "yyyyMMdd-HHmmss") - UploadLog.log"
Set-ExecutionPolicy Bypass -Scope "Process" -Force

#install rereqs
(get-PackageProvider -Name "NuGet" -Force)
if (Get-Module -Name "IntuneWin32App" -ListAvailable) {Import-Module -Name "IntuneWin32App"} else {Install-Module  -Name "IntuneWin32App" -Scope CurrentUser -Force;Import-Module -Name "IntuneWin32App"}
if (Get-Module -Name "MSAL.PS"        -ListAvailable) {Import-Module -Name "MSAL.PS"       } else {Install-Module  -Name "MSAL.PS"        -Scope CurrentUser -Force;Import-Module -Name "MSAL.PS"}


$TenantID = Read-Host -Prompt "TenantID / Name (Company.Onmicrosoft.com)"
if ($tenantID -like "*@*") {$TenantID = ($TenantID -split "@")[-1]}
$BackgroundURL = (Read-Host -Prompt "URL to background desktop image").Replace("&","``&")


##############
### Config ###
##############

if (test-path "$psscriptroot\Package") {
    $Win32AppPackageSourceFolder = "$psscriptroot\Package"
    $Win32AppPackageSetupFile    = "Deploy-Application.exe"
    $Win32AppPackageOutputFolder = "$psscriptroot"
    $Win32AppPackage             = New-IntuneWin32AppPackage -SourceFolder $Win32AppPackageSourceFolder -SetupFile $Win32AppPackageSetupFile -OutputFolder $Win32AppPackageOutputFolder -Verbose
}



Connect-MSIntuneGraph -TenantID $TenantID


#Create package in intune for deploying to the users.
$IntuneWin32AppParameters = @{
	FilePath             = (Get-ChildItem -PSPath $psscriptroot -Filter "*.intunewin").FullName
	DisplayName          = "Set User Desktop Background" 
	Description          = "Set the users wallpaper"
	Publisher            = "Thomas Steendijk"
	InstallExperience    = "user"
	RestartBehavior      = "basedOnReturnCode" 
	DetectionRule        = New-IntuneWin32AppDetectionRuleFile -Path "%appdata%" -Existence -FileOrFolder "Wallpaper.png" -DetectionType exists
	Icon 	 	         = New-IntuneWin32AppIcon -FilePath "$psscriptroot\package\AppDeployToolkit\AppDeployToolkitLogo.png"  
	Verbose              = $true
      AppVersion           = "Latest"
	Notes                = "Set the desktop for the user to the url set in -wallpaperURL (Warning if the url has a & needs a `` before it to escape it)"
	RequirementRule      = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease 1607
	InstallCommandLine   = "Deploy-Application.exe -wallpaperURL ""$BackgroundURL"" -wallpaperLocation ""`$env:APPDATA\Wallpaper.png"" -DeployMode silent"
	UninstallCommandLine = "Deploy-Application.exe Uninstall"
}

$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99