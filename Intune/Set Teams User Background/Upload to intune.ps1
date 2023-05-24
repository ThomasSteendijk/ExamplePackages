Start-Transcript -Path "$(get-date -Format "yyyyMMdd-HHmmss") - UploadLog.log"
Set-ExecutionPolicy Bypass -Scope "Process" -Force

#install rereqs
(get-PackageProvider -Name "NuGet" -Force)
if (Get-Module -Name "IntuneWin32App" -ListAvailable) {Import-Module -Name "IntuneWin32App"} else {Install-Module  -Name "IntuneWin32App" -Scope CurrentUser -Force;Import-Module -Name "IntuneWin32App"}
if (Get-Module -Name "MSAL.PS"        -ListAvailable) {Import-Module -Name "MSAL.PS"       } else {Install-Module  -Name "MSAL.PS"        -Scope CurrentUser -Force;Import-Module -Name "MSAL.PS"}


$TenantID = Read-Host -Prompt "TenantID / Name (company.onmicrosoft.com)"
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
	DisplayName          = "Teams Custom backgrounds" 
	Description          = "Set custom backgrounds to the users teams"
	Publisher            = "Thomas Steendijk"
	InstallExperience    = "user"
	RestartBehavior      = "basedOnReturnCode" 
	DetectionRule        = $(get-childitem .\package\Files |  foreach-object -process {New-IntuneWin32AppDetectionRuleFile -Path "%appdata%\Microsoft\Teams\Backgrounds\Uploads" -Existence -FileOrFolder "$($_.name)" -DetectionType exists})
	Icon 	 	         = New-IntuneWin32AppIcon -FilePath "$psscriptroot\package\AppDeployToolkit\AppDeployToolkitLogo.png"  
	Verbose              = $true
      AppVersion           = "1.0"
	Notes                = "adds the following backgrounds:$(get-childitem .\package\Files |  foreach-object -process {"`n- $($_.name)"})"
	RequirementRule      = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease "W10_1607"
	InstallCommandLine   = "Deploy-Application.exe"
	UninstallCommandLine = "Deploy-Application.exe Uninstall"
}

$Win32App = Add-IntuneWin32App @IntuneWin32AppParameters
$Win32App | ConvertTo-Json -Depth 99