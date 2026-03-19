#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: 'flutter' not found in PATH."
  exit 1
fi

echo "Bootstrapping Dart/Flutter packages (flutter pub get)..."

found_any=0
while IFS= read -r pubspec; do
  found_any=1
  dir="$(dirname "$pubspec")"
  echo "==> flutter pub get ($dir)"
  (cd "$dir" && flutter pub get)
done < <(
  find "$ROOT_DIR" \
    -name "pubspec.yaml" \
    -not -path "*/.git/*" \
    -not -path "*/.dart_tool/*" \
    -not -path "*/.pub/*" \
    -not -path "*/build/*" \
    -print \
  | sort
)

if [ "$found_any" -eq 0 ]; then
  echo "No pubspec.yaml files found under: $ROOT_DIR"
  exit 1
fi

echo "Done."

