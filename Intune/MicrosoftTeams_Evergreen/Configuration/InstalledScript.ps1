if (!(test-path C:\temp)) {mkdir C:\temp | out-null}
$LF = "C:\temp\log.log"
$AN = "microsoft.teams"
"[$(get-date)] [Detection] Starting winget search for $AN" | Out-File -Append -FilePath $LF
$wg = $(winget list $AN --accept-source-agreements) 
if (!($wg -like "*Available*") -and !($wg -like "*No installed package*")) {
	"[$(get-date)] [Detection] $AN installed"|Out-File -Append -FilePath $LF
	$true
} else {"[$(get-date)] [Detection] $AN not installed"|Out-File -Append -FilePath $LF}