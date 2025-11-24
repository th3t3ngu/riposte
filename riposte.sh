#!/bin/bash

AUTHLOG="/var/log/auth.log"
EXCLUDE_COUNTRIES=("US" "United States" "CA" "Canada" "TR" "Turkey" "DE" "Germany" "Unknown") # Countries that are sorted out when using --analyze

show_help() {
    echo "Usage: riposte.sh [OPTION]"
    echo -e "\033[33mShow unique IPs in /var/log/auth.log - or scan attacking IPs for an open HTTP port\033[0m"
    echo
    echo -e "\033[4mOptions:\033[0m"
    echo "  --show         List unique IPs, sorted by frequency and country of origin" 
    echo "  --analyze      Scans the IPs for open HTTP-ports and writes a report from the results."
    echo "  --help         Show this help"
    echo
}


case "$1" in
    --show)
        ips=$(grep -oP '(?<=rhost=)[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$AUTHLOG" | sort -u)

        echo "Analyze the country of origin of blocked IPs. ..."
        echo

        declare -A country_count

        for ip in $ips; do
            info=$(geoiplookup "$ip" | grep 'GeoIP Country Edition')
    
            country=$(echo "$info" | awk -F ', ' '{print $2}')
    
            # set to unknown if string empty
            [[ -z "$country" ]] && country="Unknown"
    
            ((country_count["$country"]++))
        done

    echo "Top countries of blocked connections:"
    echo

    for country in "${!country_count[@]}"; do
        echo "${country_count[$country]} × $country"
    done | sort -nr | head -20
        ;;
    --analyze)
        
        rm ips.tmp 2>&1
        echo "[*] Collecting uniquie IP-Adresses from /var/log/auth.log…"

        IPS=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$AUTHLOG" | sort -u)

    for IP in $IPS; do
        GEO=$(geoiplookup "$IP")

        CC=$(echo "$GEO" | sed -n 's/.*GeoIP Country Edition: \([A-Z][A-Z]\), .*/\1/p')

        COUNTRY=$(echo "$GEO" | sed -n 's/.*GeoIP Country Edition: [A-Z][A-Z], \(.*\)/\1/p')

        if [[ -z "$CC" ]]; then
            COUNTRY="Unknown"
            CC="Unknown"
        fi

        SKIP=false
        for EX in "${EXCLUDE_COUNTRIES[@]}"; do
            if [[ "$CC" == "$EX" || "$COUNTRY" == "$EX" ]]; then
                SKIP=true
                break
            fi
    done

        if [[ "$SKIP" == false ]]; then
            #echo "$IP  →  $CC, $COUNTRY"
            echo "$IP" >> ips.tmp
        fi
    done
    bash check_http.sh
        ;;
    --help|-h)
        show_help
        ;;
    *)
        echo 
        show_help
        exit 1
        ;;
esac