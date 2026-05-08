#!/bin/zsh
# Registers a UTI for .msg files and patches the Finder Quick Action so the
# menu item only appears when .msg files are selected.
#
# Run once after installing the Quick Action:
#   ./register_uti.sh "Convert to EML"   # pass your Quick Action name
#
# The helper app at ~/.msg2eml-helper/ must stay in place — moving or
# deleting it will unregister the UTI.

set -e

HELPER_DIR="$HOME/.msg2eml-helper"
APP_BUNDLE="$HELPER_DIR/MSGFile.app"
CONTENTS="$APP_BUNDLE/Contents"
UTI="com.local.msg-file"
WORKFLOW_NAME="${1:-Convert to EML}"
WORKFLOW_PLIST="$HOME/Library/Services/$WORKFLOW_NAME.workflow/Contents/Info.plist"

# ── 1. Create minimal app bundle that declares the UTI ────────────────────────
mkdir -p "$CONTENTS"

/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.local.msgfile-uti" \
    -c "Add :CFBundleName string MSGFile" \
    -c "Add :CFBundleVersion string 1.0" \
    -c "Add :UTExportedTypeDeclarations array" \
    -c "Add :UTExportedTypeDeclarations:0 dict" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeIdentifier string $UTI" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeDescription string 'MSG Email File'" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeConformsTo array" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeConformsTo:0 string public.data" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeTagSpecification dict" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeTagSpecification:public.filename-extension array" \
    -c "Add :UTExportedTypeDeclarations:0:UTTypeTagSpecification:public.filename-extension:0 string msg" \
    "$CONTENTS/Info.plist" 2>/dev/null || true  # ignore "already exists" errors

# ── 2. Register with Launch Services ─────────────────────────────────────────
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
    -f "$APP_BUNDLE"
echo "UTI registered: $UTI (.msg)"

# ── 3. Patch the Quick Action Info.plist ─────────────────────────────────────
if [[ ! -f "$WORKFLOW_PLIST" ]]; then
    echo ""
    echo "Quick Action not found: $WORKFLOW_PLIST"
    echo "Save the Quick Action in Automator first, then re-run this script."
    echo "Or pass the correct name: ./register_uti.sh \"Your Action Name\""
    exit 1
fi

/usr/libexec/PlistBuddy \
    -c "Delete :NSServices:0:NSSendFileTypes" \
    "$WORKFLOW_PLIST" 2>/dev/null || true

/usr/libexec/PlistBuddy \
    -c "Add :NSServices:0:NSSendFileTypes array" \
    -c "Add :NSServices:0:NSSendFileTypes:0 string $UTI" \
    "$WORKFLOW_PLIST"

/System/Library/CoreServices/pbs -update
echo "Quick Action patched: $WORKFLOW_PLIST"
echo ""
echo "Restart Finder to apply: killall Finder"
