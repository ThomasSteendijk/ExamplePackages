Start-Transcript -Path "$(get-date -Format "yyyyMMdd-HHmmss") - UploadLog.log"
Set-ExecutionPolicy Bypass -Scope "Process" -Force

#install rereqs
(get-PackageProvider -Name "NuGet" -Force)
if (Get-Module -Name "IntuneWin32App" -ListAvailable) {Import-Module -Name "IntuneWin32App"} else {Install-Module  -Name "IntuneWin32App" -Scope CurrentUser -Force;Import-Module -Name "IntuneWin32App"}
if (Get-Module -Name "MSAL.PS"        -ListAvailable) {Import-Module -Name "MSAL.PS"       } else {Install-Module  -Name "MSAL.PS"        -Scope CurrentUser -Force;Import-Module -Name "MSAL.PS"}


$TenantID = Read-Host -Prompt "TenantID / Name (Company.Onmicrosoft.com)"
if ($tenantID -like "*@*") {$TenantID = ($TenantID -split "@")[-1]}



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
	DisplayName          = "Zoom" 
	Description          = "Zoom's secure, reliable video platform powers all of your communication needs, including meetings, chat, phone, webinars, and online events."
	Publisher            = "Zoom"
	InstallExperience    = "user"
	RestartBehavior      = "basedOnReturnCode" 
	DetectionRule        = New-IntuneWin32AppDetectionRuleFile -Path "%appdata%\Zoom\bin" -Existence -FileOrFolder "Zoom.exe" -DetectionType exists
	Icon 	 	         = New-IntuneWin32AppIcon -FilePath "$psscriptroot\package\AppDeployToolkit\AppDeployToolkitLogo.png"  
	Verbose              = $true
    AppVersion           = "Latest"
	Notes                = "Assign this application to install Zoom to the user."
	RequirementRule      = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease 1607
	InstallCommandLine   = "Deploy-Application.exe"
	UninstallCommandLine = "Deploy-Application.exe Uninstall"
}

$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99

start-sleep -s 10

#Create a package in intune to update out of date versions of Obsidian
#Only changing and/or adding parameters to $IntuneWin32AppParameters

$IntuneWin32AppParameters.DisplayName               += " (Upgrader)" 
$IntuneWin32AppParameters.DetectionRule             = New-IntuneWin32AppDetectionRuleScript -ScriptFile "$PSScriptRoot\Configuration\InstalledScript.ps1"
$IntuneWin32AppParameters.Notes                     = "This packages updates zoom if it detects that the user has a out of date version.If the users does not have Zoom installed teams will not be installed. User gets a popup if they want to update or not if the application is in use. Assign as required to a group or all users."
$IntuneWin32AppParameters.AdditionalRequirementRule = New-IntuneWin32AppRequirementRuleScript -ScriptFile "$PSScriptRoot\Configuration\RequirementsScript.ps1" -StringOutputDataType -StringComparisonOperator equal -StringValue "true" -ScriptContext User

#currently commented away because winget does not work as expected with zoom because zoom repoorts its version number incorreclty (1.2.3(4) instead of 1.2.3.4 as winget expects)
#uncomment line below to upload anyways.
#$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99