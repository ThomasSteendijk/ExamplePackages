$exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" | Select-Object -ExpandProperty Path

if (!(test-path C:\temp)) {mkdir C:\temp | out-null}
$LF = "C:\temp\log.log"
$AN = "Google.Chrome"
"[$(get-date)] [Requirement check] Starting winget search for $AN" | Out-File -Append -FilePath $LF
$wg = $(.$exe list $AN --accept-source-agreements) 
if ($wg -like "*Available*") {
	"[$(get-date)] [Requirement check] $AN detected but out-of-date"| Out-File -Append -FilePath $LF
	$true
} else {"[$(get-date)] [Requirement check] $AN not detected or up-to-date"| Out-File -Append -FilePath $LF}