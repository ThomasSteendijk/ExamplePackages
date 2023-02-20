if (!(test-path C:\temp)) {mkdir C:\temp | out-null}
$LF = "C:\temp\log.log"
$AN = "Microsoft.VCRedist.2015+.x64"
"[$(get-date)] [Detection] Starting winget search for $AN" | Out-File -Append -FilePath $LF
$exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" | Select-Object -ExpandProperty Path
$wg = $(.$exe list $AN --accept-source-agreements) 
if (!($wg -like "*Available*") -and !($wg -like "*No installed package*") -and ($wg)) {
	"[$(get-date)] [Detection] $AN installed"|Out-File -Append -FilePath $LF
	$true
} else {"[$(get-date)] [Detection] $AN not installed"|Out-File -Append -FilePath $LF}