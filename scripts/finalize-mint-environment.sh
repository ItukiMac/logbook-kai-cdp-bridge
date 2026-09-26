#!/usr/bin/env bash
set -euo pipefail

LOGBOOK_DIR="${LOGBOOK_DIR:-$HOME/logbook-kai}"
AUTO_SRC="${AUTO_SRC:-}"
ARCHIVE="$LOGBOOK_DIR/archive-runtime/$(date +%Y%m%d-%H%M%S)"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP="$AUTOSTART_DIR/auto.sh.desktop"

if [[ -z "$AUTO_SRC" ]]; then
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    AUTO_SRC="$ROOT/examples/auto.sh"
fi

[[ -f "$AUTO_SRC" ]] || { echo "NG: auto.sh source not found: $AUTO_SRC" >&2; exit 1; }
[[ -f "$LOGBOOK_DIR/logbook-kai.jar" ]] || { echo "NG: logbook-kai.jar not found" >&2; exit 1; }

mkdir -p "$ARCHIVE" "$AUTOSTART_DIR"

if [[ -f "$LOGBOOK_DIR/auto.sh" ]]; then
    cp -a "$LOGBOOK_DIR/auto.sh" "$ARCHIVE/auto.sh.before"
fi
if [[ -f "$DESKTOP" ]]; then
    cp -a "$DESKTOP" "$ARCHIVE/auto.sh.desktop.before"
fi

install -m 0755 "$AUTO_SRC" "$LOGBOOK_DIR/auto.sh"

cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=艦これ環境
Comment=航海日誌改とKLB Chrome Extensionを起動
Exec=$LOGBOOK_DIR/auto.sh
Terminal=false
X-GNOME-Autostart-enabled=true
X-MATE-Autostart-enabled=true
EOF

chmod 0644 "$DESKTOP"

echo '=== active autostart ==='
sed -n '1,20p' "$DESKTOP"

echo
echo '=== auto.sh ==='
sed -n '1,160p' "$LOGBOOK_DIR/auto.sh"

echo
echo '=== stale MessageFlow references in active startup ==='
if grep -RniE 'messageflow|8890|renderer-process-limit' \
    "$LOGBOOK_DIR/auto.sh" "$DESKTOP" 2>/dev/null; then
    echo 'NG: active startup still contains legacy reference' >&2
    exit 1
else
    echo 'OK: active startup has no MessageFlow/8890/renderer-process-limit reference'
fi

echo
echo "Rollback archive: $ARCHIVE"
