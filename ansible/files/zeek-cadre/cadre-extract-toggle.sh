#!/bin/bash
# cadre-extract-toggle.sh — Enable/disable Zeek file extraction (session-only)
# Usage: sudo ./cadre-extract-toggle.sh enable|disable|status

ZEEK_LOCAL="/opt/zeek/share/zeek/site/local.zeek"
EXTRACT_LINE="@load policy/frameworks/files/extract-all-files.zeek"
EXTRACT_DIR="/opt/zeek/extracted"

case "$1" in
    enable)
        if grep -q "$EXTRACT_LINE" "$ZEEK_LOCAL"; then
            echo "File extraction already enabled."
        else
            echo "$EXTRACT_LINE" >> "$ZEEK_LOCAL"
            mkdir -p "$EXTRACT_DIR"
            /opt/zeek/bin/zeekctl deploy 2>&1 | tail -3
            echo "File extraction ENABLED. Output: $EXTRACT_DIR"
        fi
        ;;
    disable)
        if grep -q "$EXTRACT_LINE" "$ZEEK_LOCAL"; then
            sed -i "\|$EXTRACT_LINE|d" "$ZEEK_LOCAL"
            /opt/zeek/bin/zeekctl deploy 2>&1 | tail -3
            echo "File extraction DISABLED."
        else
            echo "File extraction was not enabled."
        fi
        ;;
    status)
        if grep -q "$EXTRACT_LINE" "$ZEEK_LOCAL"; then
            echo "File extraction: ENABLED"
            ls -la "$EXTRACT_DIR" 2>/dev/null | head -5
        else
            echo "File extraction: DISABLED"
        fi
        ;;
    *)
        echo "Usage: $0 enable|disable|status"
        exit 1
        ;;
esac
