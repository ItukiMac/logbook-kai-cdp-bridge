# Linux Mint operations

## Finalize autostart

`scripts/finalize-mint-environment.sh` installs the current KLB startup script
to `$HOME/logbook-kai/auto.sh`, rewrites the MATE autostart entry, and archives the
previous startup files under `archive-runtime/`.

The active startup intentionally contains no MessageFlow/8890 dependency and no
`renderer-process-limit` override.

## Backup

`scripts/backup-mint-environment.sh` creates a mode-600 tar.gz plus SHA256 manifest.
It backs up the logbook-kai state/config, KLB plugin/extension, MATE autostart,
minimal Chrome extension registration settings, OBS, Deskflow, and Linux RustDesk config.

Chrome cookies and login databases are intentionally excluded.

By default the backup is created under `$HOME/logbook-kai/backups`. For an off-OS-disk
backup, run with `BACKUP_DEST=/mounted/path`.

Linux RustDesk settings follow the confirmed locations:

- `~/.config/rustdesk/RustDesk.toml`
- `~/.config/rustdesk/RustDesk2.toml`
- `~/.config/rustdesk/config.toml`

## OBS recording mount verification

`scripts/verify-obs-recording-mount.sh` reads OBS recording-path candidates from both
native and Flatpak config locations, then runs `findmnt -T` and `df -hT` for each path.
It also prints non-comment `/etc/fstab` entries and active systemd mount units.

This verification is intentionally read-only.
