Start-Transcript -Path "$(get-date -Format "yyyyMMdd-HHmmss") - UploadLog.log"
Set-ExecutionPolicy Bypass -Scope "Process" -Force

#Install prereqs
Install-PackageProvider -Name NuGet            -Scope CurrentUser -Force
Install-Module          -Name "MSAL.PS"        -Scope CurrentUser -Force
Install-Module          -Name "IntuneWin32App" -Scope CurrentUser -Force

Import-Module -Name "MSAL.PS"
Import-Module -Name "IntuneWin32App"

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
	DisplayName          = "Microsoft Teams" 
	Description          = "Make amazing things happen together at home, work, and school."
	Publisher            = "Microsoft"
	InstallExperience    = "user"
	RestartBehavior      = "basedOnReturnCode" 
	DetectionRule        = New-IntuneWin32AppDetectionRuleFile -Path "%localappdata%\Microsoft\Teams" -Existence -FileOrFolder "Update.exe" -DetectionType exists
	Icon 	 	         = New-IntuneWin32AppIcon -FilePath "$psscriptroot\Configuration\AppLogo.png" 
	Verbose              = $true
      AppVersion           = "Latest"
	Notes                = "Assign this application to install microsoft teams to the user."
	RequirementRule      = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease 1607
	InstallCommandLine   = "Deploy-Application.exe"
	UninstallCommandLine = "Deploy-Application.exe Uninstall"
}

$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99



#Create a package in intune to update out of date versions of Microsoft teams
$IntuneWin32AppParameters = @{
	FilePath             = (Get-ChildItem -PSPath $psscriptroot -Filter "*.intunewin").FullName
	DisplayName          = "Microsoft Teams (Upgrader)" 
	Description          = "Make amazing things happen together at home, work, and school."
	Publisher            = "Microsoft"
	InstallExperience    = "user"
	RestartBehavior      = "basedOnReturnCode" 
	DetectionRule        = New-IntuneWin32AppDetectionRuleScript -ScriptFile "$PSScriptRoot\Configuration\InstalledScript.ps1"
	Icon 	 	         = New-IntuneWin32AppIcon -FilePath "$psscriptroot\Configuration\AppLogo.png" 
	Verbose              = $true
    AppVersion             = "Latest"
	Notes                = "This packages updates microsoft teams if it detects that the user has a out of date version.If the users does not have teams installed teams will not be installed. User gets a popup if they want to update or not if the application is in use. Assign as required to a group or all users."
	RequirementRule      = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease 1607
	InstallCommandLine   = "Deploy-Application.exe"
	UninstallCommandLine = "Deploy-Application.exe Uninstall"
	AdditionalRequirementRule      = New-IntuneWin32AppRequirementRuleScript -ScriptFile "$PSScriptRoot\Configuration\RequirementsScript.ps1" -StringOutputDataType -StringComparisonOperator equal -StringValue "true" -ScriptContext user
}

$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99