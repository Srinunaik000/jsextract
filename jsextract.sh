#!/bin/bash

# Create base directory for JS recon
BASE_DIR="js_recon"
mkdir -p "$BASE_DIR/output" "$BASE_DIR/extracted_endpoints" "$BASE_DIR/extracted_secrets" "$BASE_DIR/linkfinder" "$BASE_DIR/secretfinder"

show_help() {
    echo -e "Usage: $0 [options]\n"
    echo "Options:"
    echo "  -u <js_url>        Extract from single JS URL"
    echo "  -f <file>          Extract from list of JS URLs"
    echo "  -d <domain.com>    Run full recon using subjs, gau, waybackurls"
    echo "  -h                 Show this help message"
    exit 0
}

extract_from_js() {
    local js_url="$1"
    local hash_name
    hash_name=$(echo "$js_url" | md5sum | cut -d ' ' -f1)
    local temp_file="temp_$hash_name.js"

    echo "[*] Downloading: $js_url"
    curl -s "$js_url" -o "$temp_file"

    if [ ! -s "$temp_file" ]; then
        echo "[-] Failed to download or empty file: $js_url"
        rm -f "$temp_file"
        return
    fi

    echo "[+] Extracting from: $js_url"

    # Extract endpoints (manual)
    grep -oP '(["'\''])(https?:\/\/[^\s"'\'']+|\/[a-zA-Z0-9_\-/]+)(["'\''])' "$temp_file" \
        | sed 's/["'\'']//g' | sort -u > "$BASE_DIR/extracted_endpoints/$hash_name.txt"

    # Extract secrets (manual)
    grep -Eoi '([a-zA-Z_]*key[a-zA-Z_]*|username|access|token|authorization|bearer|password|secret)[\"'\'' ]*[:=][\"'\'' ]*[a-zA-Z0-9_\-\.=]{10,}' "$temp_file" \
        | sort -u > "$BASE_DIR/extracted_secrets/$hash_name.txt"

    # Run LinkFinder
    echo "[*] Running LinkFinder..."
    linkfinder -i "$temp_file" -o cli > "$BASE_DIR/linkfinder/$hash_name.txt"

    # Run SecretFinder
    echo "[*] Running SecretFinder..."
    secretfinder -i "$js_url" -o cli > "$BASE_DIR/secretfinder/$hash_name.txt"

    rm "$temp_file"
}

# Main flag handling
while getopts ":u:f:d:h" opt; do
    case $opt in
        u)
            echo "[*] Extracting from single JS URL"
            extract_from_js "$OPTARG"
            ;;
        f)
            echo "[*] Extracting from list of JS URLs: $OPTARG"
            while read -r url; do
                [[ -z "$url" || "$url" == \#* ]] && continue
                extract_from_js "$url"
            done < "$OPTARG"
            ;;
        d)
            DOMAIN="$OPTARG"
            echo "[*] Running full JS recon on: $DOMAIN"

            echo "[*] Running subjs..."
            subfinder -d "$DOMAIN" -silent | subjs > "$BASE_DIR/output/subjs_js.txt"

            echo "[*] Running gau..."
            gau "$DOMAIN" | grep "\.js" > "$BASE_DIR/output/gau_js.txt"

            echo "[*] Running waybackurls..."
            echo "$DOMAIN" | waybackurls | grep "\.js" > "$BASE_DIR/output/wayback_js.txt"

            cat "$BASE_DIR"/output/*_js.txt | sort -u > "$BASE_DIR/output/js_links.txt"
            echo "[+] Total JS files found: $(wc -l < "$BASE_DIR/output/js_links.txt")"

            while read -r js_url; do
                [[ -z "$js_url" || "$js_url" == \#* ]] && continue
                extract_from_js "$js_url"
            done < "$BASE_DIR/output/js_links.txt"
            ;;
        h)
            show_help
            ;;
        \?)
            echo "[-] Unknown option: -$OPTARG"
            show_help
            ;;
        :)
            echo "[-] Missing argument for -$OPTARG"
            show_help
            ;;
    esac
done
