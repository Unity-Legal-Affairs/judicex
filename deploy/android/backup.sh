#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

DATA="$HOME/judicex-data"
DEST="$HOME"
STAMP="$(date +%Y%m%d_%H%M%S)"
DB="$DATA/rahimi.db"
FILES="$DATA/rahimi_files"

if [ ! -f "$DB" ]; then
  echo "Database not found: $DB"
  exit 1
fi

mkdir -p "$HOME/judicex-backups"
if [ -d "$FILES" ]; then
  tar -czf "$HOME/judicex-backups/rahimi-$STAMP.tar.gz" -C "$DATA" rahimi.db rahimi_files
else
  tar -czf "$HOME/judicex-backups/rahimi-$STAMP.tar.gz" -C "$DATA" rahimi.db
fi

echo "Backup created: $HOME/judicex-backups/rahimi-$STAMP.tar.gz"
echo "Copy this backup to a separate secure location."
