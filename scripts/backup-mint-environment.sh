#!/usr/bin/env bash
set -euo pipefail

LOGBOOK_DIR="${LOGBOOK_DIR:-$HOME/logbook-kai}"
DEST_ROOT="${BACKUP_DEST:-$LOGBOOK_DIR/backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

umask 077
mkdir -p "$DEST_ROOT"
OUT="$DEST_ROOT/kancolle-env-backup-$STAMP.tar.gz"
MANIFEST="$WORK/MANIFEST.txt"
STAGE="$WORK/kancolle-env-backup-$STAMP"
mkdir -p "$STAGE"

copy_path() {
    local src="$1"
    local rel="$2"
    if [[ -e "$src" ]]; then
        mkdir -p "$STAGE/$(dirname "$rel")"
        cp -a "$src" "$STAGE/$rel"
        printf 'INCLUDED\t%s\n' "$src" >> "$MANIFEST"
    else
        printf 'MISSING\t%s\n' "$src" >> "$MANIFEST"
    fi
}

copy_path "$LOGBOOK_DIR/config" "logbook-kai/config"
copy_path "$LOGBOOK_DIR/battlelog" "logbook-kai/battlelog"
copy_path "$LOGBOOK_DIR/資材ログ.csv" "logbook-kai/資材ログ.csv"
copy_path "$LOGBOOK_DIR/plugins/kancolle-cdp-bridge.jar" "logbook-kai/plugins/kancolle-cdp-bridge.jar"
copy_path "$LOGBOOK_DIR/cdp-bridge/extension" "logbook-kai/cdp-bridge/extension"
copy_path "$LOGBOOK_DIR/auto.sh" "logbook-kai/auto.sh"

copy_path "$HOME/.config/autostart/auto.sh.desktop" ".config/autostart/auto.sh.desktop"

# Chrome: unpacked extension registration/settings only.
# Cookie/Login Data 等の認証情報は意図的に含めない。
copy_path "$HOME/.config/google-chrome/Default/Preferences" ".config/google-chrome/Default/Preferences"
copy_path "$HOME/.config/google-chrome/Default/Secure Preferences" ".config/google-chrome/Default/Secure Preferences"
copy_path "$HOME/.config/google-chrome/Local State" ".config/google-chrome/Local State"

copy_path "$HOME/.config/obs-studio" ".config/obs-studio"
copy_path "$HOME/.var/app/com.obsproject.Studio/config/obs-studio" ".var/app/com.obsproject.Studio/config/obs-studio"
copy_path "$HOME/.config/deskflow" ".config/deskflow"
copy_path "$HOME/.local/share/deskflow" ".local/share/deskflow"
copy_path "$HOME/.config/rustdesk/RustDesk.toml" ".config/rustdesk/RustDesk.toml"
copy_path "$HOME/.config/rustdesk/RustDesk2.toml" ".config/rustdesk/RustDesk2.toml"
copy_path "$HOME/.config/rustdesk/config.toml" ".config/rustdesk/config.toml"

{
    echo
    echo "=== system ==="
    uname -a
    echo
    echo "=== filesystem ==="
    df -hT
    echo
    echo "=== mounts ==="
    findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS
    echo
    echo "=== Direct Bridge health ==="
    curl -fsS http://127.0.0.1:8891/health 2>/dev/null || true
} >> "$MANIFEST"

cp "$MANIFEST" "$STAGE/MANIFEST.txt"

tar -C "$WORK" -czf "$OUT" "$(basename "$STAGE")"
sha256sum "$OUT" > "$OUT.sha256"

echo "OK: $OUT"
echo "SHA256: $(cat "$OUT.sha256")"
echo "権限: $(stat -c '%a %U:%G' "$OUT")"
echo
echo "注意: BACKUP_DESTを指定しない場合はOSディスク上のローカルバックアップです。"
