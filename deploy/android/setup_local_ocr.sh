#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/judicex"
PY="$ROOT/.venv/bin/python"
TESSDATA="$PREFIX/share/tessdata"
TMP="$TMPDIR/fas.traineddata"

echo "== Judicex: local Persian OCR setup (Poppler + Tesseract) =="

if [ ! -x "$PY" ]; then
  echo "ERROR: Judicex virtual environment not found at $PY"
  exit 1
fi

echo "Installing local OCR tools from Termux packages..."
pkg install -y tesseract poppler curl
mkdir -p "$TESSDATA"

echo "Downloading official Persian OCR data (fas)..."
curl -fL --retry 3 \
  "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main/fas.traineddata" \
  -o "$TMP"
test -s "$TMP"
mv "$TMP" "$TESSDATA/fas.traineddata"

echo
echo "== Checking local OCR commands =="
command -v tesseract
command -v pdftoppm
tesseract --list-langs

if ! tesseract --list-langs 2>&1 | grep -qx "fas"; then
  echo "ERROR: Persian language data was not recognized by Tesseract."
  exit 1
fi
if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "ERROR: Poppler pdftoppm is unavailable."
  exit 1
fi

echo
echo "== Python dependencies =="
"$PY" - <<'PY'
import importlib.util
for name, module in [("pypdf", "pypdf"), ("python-docx", "docx"), ("Pillow", "PIL")]:
    print(f"{name}:", "OK" if importlib.util.find_spec(module) else "MISSING")
print("PyMuPDF: not required")
PY

echo
echo "DONE: Image and scanned-PDF OCR use local Tesseract + Poppler."
echo "Document contents are not sent to cloud OCR services."
