#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/judicex"
DATA="$HOME/judicex-data"
DB="$DATA/rahimi.db"
SECRET_FILE="$DATA/.secret_key"

if [ ! -f "$ROOT/.venv/bin/activate" ]; then
  echo "Judicex is not installed. Run: bash $ROOT/deploy/android/install.sh"
  exit 1
fi

mkdir -p "$DATA"
chmod 700 "$DATA"
if [ ! -s "$SECRET_FILE" ]; then
  (umask 077; python -c 'import secrets; print(secrets.token_urlsafe(48))' > "$SECRET_FILE")
fi
chmod 600 "$SECRET_FILE"

cd "$ROOT"
. .venv/bin/activate

export PYTHONUNBUFFERED=1
export JUDICEX_DEFAULT_AREA=iran
export JUDICEX_SECRET_KEY="$(cat "$SECRET_FILE")"

echo "Judicex is starting on http://127.0.0.1:5051"
echo "Keep this Termux session open while using the app."
exec python -m judicex_memory_os.web_app --db "$DB" --area iran --bind 127.0.0.1 --port 5051
