#!/bin/bash

IPLIST="ips.tmp"
OUTFILE="http_found.txt"
> "$OUTFILE"

echo "[*] Starting HTTP-Scan …"

while read -r ip; do
    [[ -z "$ip" ]] && continue

    result=$(nmap -Pn -n -T4 --open -p 80,443,8080,8000,8443,8888 "$ip" -oG -)

    http_ports=$(echo "$result" | \
        grep "Ports:" | \
        grep -Eo '[0-9]+/open/tcp//(http|https)[^/]*' | \
        cut -d/ -f1)

    if [[ -n "$http_ports" ]]; then
        for p in $http_ports; do
            echo "[+] $ip → $p"
            echo "$ip $p" >> "$OUTFILE"
        done
    else
        echo -e "\033[31m[-] $ip → no HTTP port open\033[0m"
    fi

done < "$IPLIST"

echo
echo "[*] Done. Report in $OUTFILE"
rm ips.tmp 2>&1