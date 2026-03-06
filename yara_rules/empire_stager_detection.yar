rule Empire_PowerShell_Stager
{
    meta:
        description = "Detects common Empire PowerShell stager patterns"
        author = "SecureDefense Corp - Red Team"
        reference = "MITRE ATT&CK T1059.001"
        date = "2026-01-01"

    strings:
        $s1 = "System.Net.WebClient" ascii wide
        $s2 = "DownloadString" ascii wide
        $s3 = "IEX" ascii wide
        $s4 = "Invoke-Expression" ascii wide
        $s5 = "-enc" ascii wide nocase
        $s6 = "FromBase64String" ascii wide
        $s7 = "powershell" ascii wide nocase
        $s8 = "bypass" ascii wide nocase
        $s9 = "hidden" ascii wide nocase
        $s10 = "NonInteractive" ascii wide

    condition:
        3 of them
}

rule Empire_HTTP_Listener_Indicators
{
    meta:
        description = "Detects HTTP communication patterns used by Empire listeners"
        author = "SecureDefense Corp - Red Team"
        reference = "MITRE ATT&CK T1071.001"
        date = "2026-01-01"

    strings:
        $uri1 = "/admin/get.php" ascii
        $uri2 = "/login/process.php" ascii
        $uri3 = "/news.php" ascii
        $ua1 = "Mozilla/5.0" ascii
        $cookie = "session=" ascii

    condition:
        2 of them
}

rule Empire_Base64_Launcher
{
    meta:
        description = "Detects Base64-encoded Empire launcher patterns"
        author = "SecureDefense Corp - Red Team"
        reference = "MITRE ATT&CK T1027"
        date = "2026-01-01"

    strings:
        $b64_iex = "SQBFAFGA" ascii
        $b64_webclient = "UwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0" ascii
        $ps_cmd = "powershell -noP -sta -w 1" ascii nocase

    condition:
        any of them
}
