#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/circle_wallet/example/ios"

if ! command -v pod >/dev/null 2>&1; then
  echo "Error: 'pod' (CocoaPods) not found in PATH."
  echo "Install CocoaPods first, then re-run this script."
  exit 1
fi

if [ ! -f "$IOS_DIR/Podfile" ]; then
  echo "Error: Podfile not found at: $IOS_DIR/Podfile"
  exit 1
fi

echo "Running: pod install --repo-update (cwd: $IOS_DIR)"
cd "$IOS_DIR"
pod install --repo-update "$@"

echo "Done."

