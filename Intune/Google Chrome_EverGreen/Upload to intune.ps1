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

$App_VCredist = Get-IntuneWin32App -DisplayName "Microsoft VCredist 2015+ (64-bit)" | Where-Object -Property DisplayName -EQ "Microsoft VCredist 2015+ (64-bit)"

#Create package in intune for deploying to the users.
$IntuneWin32AppParameters = @{
	FilePath             = (Get-ChildItem -PSPath $psscriptroot -Filter "*.intunewin").FullName
	DisplayName          = "Google Chrome" 
	Description          = "A more simple, secure, and faster web browser than ever, with Google’s smarts built-in."
	Publisher            = "Google LLC"
	InstallExperience    = "system"
	RestartBehavior      = "basedOnReturnCode" 
	DetectionRule        = New-IntuneWin32AppDetectionRuleFile -Path "C:\Program Files\Google\Chrome\Application" -Existence -FileOrFolder "Chrome.exe" -DetectionType exists
	Icon 	 	         = New-IntuneWin32AppIcon -FilePath "$psscriptroot\package\AppDeployToolkit\AppDeployToolkitLogo.png" 
	Verbose              = $true
      AppVersion           = "Latest"
	Notes                = "Assign this application to install Chrome to the user."
	RequirementRule      = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease 1607
	InstallCommandLine   = "ServiceUI_64.exe -process:explorer.exe Deploy-Application.exe"
	UninstallCommandLine = "ServiceUI_64.exe -process:explorer.exe Deploy-Application.exe Uninstall"
}

$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99

if ($App_VCredist) {
	Add-IntuneWin32AppDependency -ID $Win32App.id -Dependency $(New-IntuneWin32AppDependency -DependencyType AutoInstall -ID $($App_VCredist).id)
}

start-sleep -s 10

#Create a package in intune to update out of date versions of Obsidian
#Only changing and/or adding parameters to $IntuneWin32AppParameters

$IntuneWin32AppParameters.DisplayName               += " (Upgrader)" 
$IntuneWin32AppParameters.DetectionRule             = New-IntuneWin32AppDetectionRuleScript -ScriptFile "$PSScriptRoot\Configuration\InstalledScript.ps1"
$IntuneWin32AppParameters.Notes                     = "This packages updates Google Chrome if it detects that the user has a out of date version.If the users does not have Google Chrome installed Google Chrome will not be installed. User gets a popup if they want to update or not if the application is in use. Assign as required to a group or all users."
$IntuneWin32AppParameters.AdditionalRequirementRule = New-IntuneWin32AppRequirementRuleScript -ScriptFile "$PSScriptRoot\Configuration\RequirementsScript.ps1" -StringOutputDataType -StringComparisonOperator equal -StringValue "true" -ScriptContext user


$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99

if ($App_VCredist) {
	Add-IntuneWin32AppDependency -ID $Win32App.id -Dependency $(New-IntuneWin32AppDependency -DependencyType AutoInstall -ID $($App_VCredist).id)
}

