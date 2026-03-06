#!/bin/bash
# empire_api.sh - Helper script for Empire REST API interactions
# Usage: source empire_api.sh

EMPIRE_HOST="http://localhost:1337"
TOKEN_FILE="/home/ubuntu/empire_lab/.api_token"

# Load API token
load_token() {
    if [ -f "$TOKEN_FILE" ]; then
        API_TOKEN=$(cat "$TOKEN_FILE")
        echo "API token loaded."
    else
        echo "Token file not found. Generating new token..."
        refresh_token
    fi
}

# Refresh API token
refresh_token() {
    API_TOKEN=$(curl -s -X POST "$EMPIRE_HOST/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "username=empireadmin&password=password123" | jq -r '.access_token')
    echo "$API_TOKEN" > "$TOKEN_FILE"
    echo "New API token saved."
}

# Generic API call function
empire_api() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    if [ -z "$API_TOKEN" ]; then
        load_token
    fi

    if [ -n "$data" ]; then
        curl -s -X "$method" "$EMPIRE_HOST/api/v2$endpoint" \
          -H "Authorization: Bearer $API_TOKEN" \
          -H "Content-Type: application/json" \
          -d "$data"
    else
        curl -s -X "$method" "$EMPIRE_HOST/api/v2$endpoint" \
          -H "Authorization: Bearer $API_TOKEN" \
          -H "Content-Type: application/json"
    fi
}

# Download a stager file by its download link
empire_download() {
    local link="$1"
    curl -s "$EMPIRE_HOST$link" \
      -H "Authorization: Bearer $API_TOKEN"
}

# Initialize token on source
load_token
echo "Empire API helper loaded. Use empire_api METHOD ENDPOINT [DATA]"
