#!/bin/sh
set -eu

DIR="$HOME/logbook-kai"
LOG_DIR="$DIR/logs"
HEALTH_URL="http://127.0.0.1:8891/health"

mkdir -p "$LOG_DIR"
exec >>"$LOG_DIR/autostart.log" 2>&1

echo "[$(date -Is)] 艦これ環境 autostart"

cd "$DIR"

if ! pgrep -u "$USER" -f '[j]ava .* -jar logbook-kai\.jar' >/dev/null 2>&1; then
    JVM_OPT=-XX:MaxMetaspaceSize=256M
    java ${JVM_OPT} \
      --enable-native-access=javafx.graphics \
      -jar logbook-kai.jar &
fi

i=0
while [ "$i" -lt 60 ]; do
    if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
        break
    fi
    i=$((i + 1))
    sleep 0.5
done

if ! curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send \
          --app-name="艦これ環境" \
          --urgency=critical \
          --expire-time=0 \
          "艦これ環境" \
          "KLB Logbook Plugin :8891 の起動確認に失敗しました"
    fi
fi

if ! pgrep -u "$USER" -f '(/opt/google/chrome/chrome|google-chrome)( |$)' >/dev/null 2>&1; then
    google-chrome \
      --silent-debugger-extension-api &
fi
