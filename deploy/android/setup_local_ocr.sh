#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/judicex"
PY="$ROOT/.venv/bin/python"
TESSDATA="$PREFIX/share/tessdata"
TMP="$TMPDIR/fas.traineddata"

echo "== Judicex: local Persian OCR setup =="

if [ ! -x "$PY" ]; then
  echo "ERROR: Judicex virtual environment not found at $PY"
  exit 1
fi

pkg install -y tesseract curl
mkdir -p "$TESSDATA"

echo "Downloading official Persian OCR data (fas)..."
curl -fL --retry 3 \
  "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main/fas.traineddata" \
  -o "$TMP"
test -s "$TMP"
mv "$TMP" "$TESSDATA/fas.traineddata"

echo
echo "== Installed Tesseract languages =="
tesseract --list-langs

if ! tesseract --list-langs 2>&1 | grep -qx "fas"; then
  echo "ERROR: Persian language data was not recognized by Tesseract."
  exit 1
fi

echo
echo "== Checking optional scanned-PDF renderer =="
if "$PY" -c 'import fitz' >/dev/null 2>&1; then
  echo "PyMuPDF already available."
else
  echo "Trying to install optional PyMuPDF for scanned PDF pages..."
  if "$PY" -m pip install 'PyMuPDF>=1.24,<2'; then
    echo "PyMuPDF installed."
  else
    echo "NOTICE: PyMuPDF could not be installed on this Termux build."
    echo "Persian OCR for image files will still work; scanned PDF OCR will report the missing dependency."
  fi
fi

echo
echo "== Final local OCR check =="
tesseract --list-langs 2>&1 | grep -E '(^List of available|^fas$|^eng$)' || true
"$PY" - <<'PY'
import importlib.util
print("PyMuPDF:", "OK" if importlib.util.find_spec("fitz") else "NOT INSTALLED (scanned PDF OCR unavailable)")
print("pypdf:", "OK" if importlib.util.find_spec("pypdf") else "MISSING")
print("python-docx:", "OK" if importlib.util.find_spec("docx") else "MISSING")
print("Pillow:", "OK" if importlib.util.find_spec("PIL") else "MISSING")
PY

echo
echo "DONE: Image OCR uses local Tesseract Persian+English."
echo "OCR requests do not send document contents to cloud services."
