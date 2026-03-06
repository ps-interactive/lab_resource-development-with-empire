#!/bin/bash
# analyze_stager.sh - Analyze generated stagers against security controls
# Usage: ./analyze_stager.sh <stager_file>

if [ -z "$1" ]; then
    echo "Usage: $0 <stager_file>"
    echo "Example: $0 /home/ubuntu/empire_lab/output/stager_output.txt"
    exit 1
fi

STAGER_FILE="$1"
YARA_RULES="/home/ubuntu/empire_lab/yara_rules/empire_stager_detection.yar"
REPORT_FILE="/home/ubuntu/empire_lab/output/analysis_report_$(date +%Y%m%d_%H%M%S).txt"

echo "============================================" | tee "$REPORT_FILE"
echo " Stager Security Analysis Report" | tee -a "$REPORT_FILE"
echo " SecureDefense Corp - Red Team QA" | tee -a "$REPORT_FILE"
echo " Date: $(date -u)" | tee -a "$REPORT_FILE"
echo "============================================" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# File metadata
echo "[*] File Information:" | tee -a "$REPORT_FILE"
echo "    Path: $STAGER_FILE" | tee -a "$REPORT_FILE"
echo "    Size: $(stat -c%s "$STAGER_FILE" 2>/dev/null || echo 'N/A') bytes" | tee -a "$REPORT_FILE"
echo "    SHA256: $(sha256sum "$STAGER_FILE" 2>/dev/null | awk '{print $1}')" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# String analysis
echo "[*] Suspicious String Analysis:" | tee -a "$REPORT_FILE"
echo "-------------------------------------------" | tee -a "$REPORT_FILE"
SUSPICIOUS_STRINGS=("powershell" "bypass" "hidden" "IEX" "Invoke-Expression" "DownloadString" "WebClient" "FromBase64String" "EncodedCommand" "-enc" "-noP" "-sta" "-w 1" "NonInteractive")
FOUND_COUNT=0
for str in "${SUSPICIOUS_STRINGS[@]}"; do
    COUNT=$(grep -oi "$str" "$STAGER_FILE" 2>/dev/null | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        echo "    [!] Found '$str' ($COUNT occurrence(s))" | tee -a "$REPORT_FILE"
        ((FOUND_COUNT++))
    fi
done
echo "    Total suspicious indicators: $FOUND_COUNT" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Entropy analysis
echo "[*] Entropy Analysis:" | tee -a "$REPORT_FILE"
B64_CHARS=$(grep -oP '[A-Za-z0-9+/=]{40,}' "$STAGER_FILE" 2>/dev/null | wc -l)
echo "    Base64-like strings (40+ chars): $B64_CHARS" | tee -a "$REPORT_FILE"
if [ "$B64_CHARS" -gt 0 ]; then
    echo "    [!] High-entropy content detected - likely encoded payload" | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"

# YARA scan
echo "[*] YARA Rule Scan:" | tee -a "$REPORT_FILE"
echo "-------------------------------------------" | tee -a "$REPORT_FILE"
if [ -f "$YARA_RULES" ]; then
    YARA_RESULT=$(yara "$YARA_RULES" "$STAGER_FILE" 2>&1)
    if [ -n "$YARA_RESULT" ]; then
        echo "    [!] YARA matches found:" | tee -a "$REPORT_FILE"
        echo "$YARA_RESULT" | while read -r line; do
            echo "        $line" | tee -a "$REPORT_FILE"
        done
    else
        echo "    [+] No YARA matches - stager may evade basic signatures" | tee -a "$REPORT_FILE"
    fi
else
    echo "    [!] YARA rules file not found at $YARA_RULES" | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"

# Risk assessment
echo "[*] Risk Assessment:" | tee -a "$REPORT_FILE"
if [ "$FOUND_COUNT" -ge 4 ]; then
    echo "    Detection Likelihood: HIGH" | tee -a "$REPORT_FILE"
    echo "    Recommendation: Apply obfuscation to reduce signature matches" | tee -a "$REPORT_FILE"
elif [ "$FOUND_COUNT" -ge 2 ]; then
    echo "    Detection Likelihood: MEDIUM" | tee -a "$REPORT_FILE"
    echo "    Recommendation: Consider additional encoding or jitter" | tee -a "$REPORT_FILE"
else
    echo "    Detection Likelihood: LOW" | tee -a "$REPORT_FILE"
    echo "    Recommendation: Stager shows minimal indicators" | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE"
