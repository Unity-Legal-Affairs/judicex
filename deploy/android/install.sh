#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/judicex"
DATA="$HOME/judicex-data"
PORT=5051

if [ ! -d "$ROOT/.git" ]; then
  echo "Repository not found at $ROOT"
  echo "Run the clone command from README_FA.md first."
  exit 1
fi

cd "$ROOT"
if [ "$(git branch --show-current)" != "Iran-legal" ]; then
  echo "Safety stop: expected branch Iran-legal."
  exit 1
fi

mkdir -p "$DATA"
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
python -m pip install -e .

echo
echo "Installation completed."
echo "Database location: $DATA/rahimi.db"
echo "Start with: bash $ROOT/deploy/android/start.sh"
echo "Then open: http://127.0.0.1:$PORT"
