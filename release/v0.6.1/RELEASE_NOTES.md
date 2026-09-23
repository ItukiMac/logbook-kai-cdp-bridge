# v0.6.1 Release Notes

Linux Mint運用の仕上げ用スクリプトを追加し、自動起動・バックアップ・OBS録画先確認を整理しました。

## Autostart

- `examples/auto.sh` をDirect Bridge運用向けに整理
- 旧MessageFlow / TCP 8890 への依存を削除
- `--renderer-process-limit` を削除
- 航海日誌改が既に起動中の場合は二重起動しない
- Chromeが既に起動中の場合は二重起動しない
- Direct Bridge :8891 の起動確認に失敗した場合はcritical通知
- 自動起動ログを `logbook-kai/logs/autostart.log` へ保存

`scripts/finalize-mint-environment.sh` は既存の `auto.sh` とMATE autostartを
`archive-runtime/` へ退避してから新設定を導入します。

## Backup

`scripts/backup-mint-environment.sh` を追加しました。

対象:
- 航海日誌改 config / battlelog / 資材ログ
- Direct Bridge plugin / extension
- auto.sh / MATE autostart
- Chromeの最小設定ファイル
- OBS
- Deskflow
- RustDesk設定

ChromeのCookie/Login Dataは含めません。
バックアップはmode 600のtar.gz + SHA256を生成します。

## OBS recording mount verification

`scripts/verify-obs-recording-mount.sh` を追加しました。

- native / Flatpak OBS設定から録画先候補を抽出
- `findmnt -T` で録画先の実体ファイルシステムを確認
- `df -hT` でOSディスク外か確認
- `/etc/fstab` とsystemd mount unitも表示

確認処理はread-onlyです。

## Packaging

Release full ZIPへ上記運用スクリプトを同梱し、GitHub Actionsでshell syntax checkを行います。
PluginのRelease内install/disableスクリプトも固定名
`$HOME/logbook-kai/plugins/kancolle-cdp-bridge.jar` を使用します。
