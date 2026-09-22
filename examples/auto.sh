#!/bin/sh
set -eu

cd "$HOME/logbook-kai/"

JVM_OPT=-XX:MaxMetaspaceSize=256M

java ${JVM_OPT} \
  --enable-native-access=javafx.graphics \
  -jar logbook-kai.jar &

i=0
while [ "$i" -lt 60 ]; do
    if curl -fsS http://127.0.0.1:8891/health >/dev/null 2>&1; then
        break
    fi
    i=$((i + 1))
    sleep 0.5
done

if ! curl -fsS http://127.0.0.1:8891/health >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send \
          "艦これ環境" \
          "航海日誌プラグイン :8891 の起動確認に失敗しました"
    fi
fi

google-chrome \
  --renderer-process-limit=3 \
  --silent-debugger-extension-api &
