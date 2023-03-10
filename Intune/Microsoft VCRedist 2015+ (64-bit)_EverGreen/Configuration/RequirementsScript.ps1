if (!(test-path C:\temp)) {mkdir C:\temp | out-null}
$LF = "C:\temp\log.log"
$AN = "Microsoft.VCRedist.2015+.x64"

$uc="{36F68A90-239C-34DF-B58C-64B30153CE35}"
$GUIDLength = $uc.Length
$MethodDefinition = @'
    [DllImport("msi.dll", CharSet = CharSet.Auto, SetLastError=true)]
    public  static extern UInt32 MsiEnumRelatedProducts(string strUpgradeCode, int reserved, int iIndex, System.Text.StringBuilder sbProductCode);
'@
$msi = Add-Type -MemberDefinition $MethodDefinition -Name 'msi' -Namespace 'Win32' -PassThru
$pc = [System.Text.StringBuilder]::new($GUIDLength)
$result = $msi::MsiEnumRelatedProducts($uc, 0, 0, $pc)

if ($result -eq 0) {
	"[$(get-date)] [Requirement check] $AN detected"| Out-File -Append -FilePath $LF
	$true
} else {"[$(get-date)] [Requirement check] $AN not detected or up-to-date"| Out-File -Append -FilePath $LF}