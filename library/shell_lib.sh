#!/bin/bash

function url_get() {
    local url="$1"
    local param="$2"
    local timeout="$3"
    if [ "x$param" != "x" ]; then
        url=$(echo "$url?$param")
    fi
    if [ "x$timeout" = "x" ]; then
        timeout=10
    fi
    local content=$(curl -sfS -m $timeout --write-out "\n%{http_code}" "$url" 2>&1)
    SURL_HTTP_CODE=$(echo "$content" | tail -1)
    SURL_HTTP_CONTENT=$(echo "$content" | sed '$d')
}
