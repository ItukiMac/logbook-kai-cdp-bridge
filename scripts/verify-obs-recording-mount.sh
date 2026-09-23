#!/usr/bin/env bash
set -euo pipefail

echo '=== OBS install ==='
command -v obs || true
flatpak info com.obsproject.Studio 2>/dev/null | sed -n '1,12p' || true

echo
echo '=== OBS recording paths ==='
found=0
for root in \
    "$HOME/.config/obs-studio" \
    "$HOME/.var/app/com.obsproject.Studio/config/obs-studio"
do
    [[ -d "$root" ]] || continue
    while IFS= read -r line; do
        found=1
        printf '%s\n' "$line"
    done < <(grep -RniE '(^|[^A-Za-z])(RecFilePath|FilePath|RecordingPath|OutputPath)=' "$root" 2>/dev/null || true)
done

if [[ "$found" -eq 0 ]]; then
    echo 'OBS設定から録画先を自動抽出できませんでした。'
fi

echo
echo '=== candidate recording directories and backing mounts ==='
paths=()
while IFS='=' read -r key value; do
    value="${value%$'\r'}"
    value="${value#\"}"
    value="${value%\"}"
    [[ "$value" = /* ]] && paths+=("$value")
done < <(
    grep -RhoE '^(RecFilePath|FilePath|RecordingPath|OutputPath)=.*$' \
      "$HOME/.config/obs-studio" \
      "$HOME/.var/app/com.obsproject.Studio/config/obs-studio" \
      2>/dev/null || true
)

if [[ "${#paths[@]}" -gt 0 ]]; then
    printf '%s\n' "${paths[@]}" | sort -u | while IFS= read -r p; do
        echo "-- $p"
        findmnt -T "$p" -o TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null || echo 'findmnt: 未確認'
        df -hT "$p" 2>/dev/null | tail -n +2 || true
    done
else
    echo '候補録画先なし'
fi

echo
echo '=== fstab / systemd mount definitions ==='
grep -vE '^[[:space:]]*(#|$)' /etc/fstab 2>/dev/null || true
systemctl list-units --type=mount --all --no-pager 2>/dev/null | sed -n '1,120p' || true
