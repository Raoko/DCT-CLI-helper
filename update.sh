#!/bin/bash
# CW Node Helper — Self-Updater
# 1. Download cw-node-helper.zip from Google Drive to your Downloads folder
# 2. Run: bash update.sh
# Your .env and bookmarks are preserved automatically.

set -e

ZIPNAME="cw-node-helper.zip"
DOWNLOADS="$HOME/Downloads"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR=$(mktemp -d)

echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CW Node Helper — Updater"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- Step 1: Find the zip in Downloads ---
if [ ! -f "$DOWNLOADS/$ZIPNAME" ]; then
    echo "  ERROR: $ZIPNAME not found in ~/Downloads"
    echo ""
    echo "  Steps:"
    echo "    1. Open: https://drive.google.com/file/d/1Bv5grjm4_YWRJE2JzcKMOy9WtRMKfbjf/view"
    echo "    2. Click the download button"
    echo "    3. Re-run: bash update.sh"
    echo ""
    exit 1
fi

# Verify it's a real zip
if ! file "$DOWNLOADS/$ZIPNAME" | grep -q "Zip"; then
    echo "  ERROR: ~/Downloads/$ZIPNAME is not a valid zip file."
    echo "         Delete it and re-download from Google Drive."
    exit 1
fi

echo "  [1/5] Found $ZIPNAME in Downloads ✓"

# --- Step 2: Back up personal files ---
echo "  [2/5] Backing up your settings..."
if [ -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env" "$TEMP_DIR/.env.bak"
    echo "        .env ✓"
else
    echo "        .env not found (will need to create one after update)"
fi

if [ -f "$SCRIPT_DIR/.cwhelper_state.json" ]; then
    cp "$SCRIPT_DIR/.cwhelper_state.json" "$TEMP_DIR/.cwhelper_state.json.bak"
    echo "        .cwhelper_state.json ✓ (bookmarks & recents)"
fi

# --- Step 3: Extract new version ---
echo "  [3/5] Extracting update..."
unzip -qo "$DOWNLOADS/$ZIPNAME" -d "$TEMP_DIR/extract"

EXTRACTED="$TEMP_DIR/extract/cw-node-helper"
if [ ! -d "$EXTRACTED" ]; then
    echo "  ERROR: Unexpected zip structure. Update aborted."
    echo "         Your current install is untouched."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# --- Step 4: Replace app files ---
echo "  [4/5] Updating files..."

# Copy all new files into current install directory
find "$EXTRACTED" -type f | while IFS= read -r src; do
    rel="${src#$EXTRACTED/}"
    # Skip .env and state from the zip — we keep ours
    [ "$rel" = ".env" ] && continue
    [ "$rel" = ".cwhelper_state.json" ] && continue
    dest_dir="$SCRIPT_DIR/$(dirname "$rel")"
    mkdir -p "$dest_dir"
    cp "$src" "$SCRIPT_DIR/$rel"
done

echo "        Files updated ✓"

# --- Step 5: Restore personal files ---
echo "  [5/5] Restoring your settings..."

if [ -f "$TEMP_DIR/.env.bak" ]; then
    cp "$TEMP_DIR/.env.bak" "$SCRIPT_DIR/.env"
    echo "        .env restored ✓"
fi

if [ -f "$TEMP_DIR/.cwhelper_state.json.bak" ]; then
    cp "$TEMP_DIR/.cwhelper_state.json.bak" "$SCRIPT_DIR/.cwhelper_state.json"
    echo "        Bookmarks & recents restored ✓"
fi

# --- Cleanup ---
rm -rf "$TEMP_DIR"
rm -f "$DOWNLOADS/$ZIPNAME"
echo "        Cleaned up ~/Downloads/$ZIPNAME ✓"

# Show new version
NEW_VER=$(grep -o 'APP_VERSION = "[^"]*"' "$SCRIPT_DIR/get_node_context.py" | head -1 | cut -d'"' -f2)
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Updated to v${NEW_VER:-???}"
echo "  Run: source load_env.sh && python3 get_node_context.py"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
