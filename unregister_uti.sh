#!/bin/zsh
# Unregisters the .msg UTI and reverts the Quick Action to show for all files.
#
# Usage: ./unregister_uti.sh "Convert to EML"

set -e

HELPER_DIR="$HOME/.msg2eml-helper"
APP_BUNDLE="$HELPER_DIR/MSGFile.app"
WORKFLOW_NAME="${1:-Convert to EML}"
WORKFLOW_PLIST="$HOME/Library/Services/$WORKFLOW_NAME.workflow/Contents/Info.plist"

# ── 1. Unregister UTI ─────────────────────────────────────────────────────────
if [[ -d "$APP_BUNDLE" ]]; then
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -u "$APP_BUNDLE"
    rm -rf "$HELPER_DIR"
    echo "UTI unregistered and helper removed: $HELPER_DIR"
else
    echo "Helper not found, skipping UTI unregistration."
fi

# ── 2. Revert Quick Action Info.plist ────────────────────────────────────────
if [[ -f "$WORKFLOW_PLIST" ]]; then
    /usr/libexec/PlistBuddy -c "Delete :NSServices:0:NSSendFileTypes" \
        "$WORKFLOW_PLIST" 2>/dev/null || true
    /System/Library/CoreServices/pbs -update
    echo "Quick Action reverted: $WORKFLOW_PLIST"
fi

killall Finder
echo "Done."
