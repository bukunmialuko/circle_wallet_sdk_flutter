#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_DIR="$ROOT_DIR/circle_wallet/example"
ENV_FILE="$EXAMPLE_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found at: $ENV_FILE"
  echo "Create it (or copy the template) and set:"
  echo "  PWSDK_MAVEN_URL"
  echo "  PWSDK_MAVEN_USERNAME"
  echo "  PWSDK_MAVEN_PASSWORD"
  exit 1
fi

# Export vars from the example .env so Gradle (System.getenv(...)) can read them.
set -a
source "$ENV_FILE"
set +a

if [ -z "${PWSDK_MAVEN_URL:-}" ]; then
  echo "Error: PWSDK_MAVEN_URL is empty. Update $ENV_FILE."
  exit 1
fi

echo "Running Android example with Maven env vars..."
cd "$EXAMPLE_DIR"

# Forward all user args to `flutter run` (debug/release/device selection, etc.)
flutter run "$@"

