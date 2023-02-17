if (!(test-path C:\temp)) {mkdir C:\temp | out-null}
$LF = "C:\temp\log.log"
$AN = "Obsidian.Obsidian"
"[$(get-date)] [Requirement check] Starting winget search for $AN" | Out-File -Append -FilePath $LF
$wg = $(winget list $AN --accept-source-agreements) 
if ($wg -like "*Available*") {
	"[$(get-date)] [Requirement check] $AN detected but out-of-date"| Out-File -Append -FilePath $LF
	$true
} else {"[$(get-date)] [Requirement check] $AN not detected or up-to-date"| Out-File -Append -FilePath $LF}