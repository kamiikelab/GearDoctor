#!/usr/bin/env bash
# Cloud Agent install: mirror the GitHub Actions CI test environment
# (.github/workflows/test.yml) so `flutter test` can be run locally.
# Idempotent: safe to run repeatedly and against a cached snapshot.
set -euo pipefail

FLUTTER_VERSION="3.47.1"
FLUTTER_DIR="$HOME/flutter"

echo "==> Installing system packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
# `flutter test` needs SQLite (sqflite_common_ffi). git/curl/unzip/xz-utils
# support cloning Flutter and unpacking the downloaded Dart SDK.
sudo apt-get install -y --no-install-recommends \
  git curl unzip xz-utils \
  libsqlite3-dev

echo "==> Installing Flutter ${FLUTTER_VERSION}"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$FLUTTER_DIR"
fi
git config --global --add safe.directory "$FLUTTER_DIR"
export PATH="$FLUTTER_DIR/bin:$PATH"

# Make flutter available in interactive terminals too.
if ! grep -q 'flutter/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "==> Configuring Flutter"
flutter config --no-analytics >/dev/null
flutter --version

echo "==> Resolving project dependencies"
cd "$(dirname "$0")/.."
flutter pub get
flutter gen-l10n

echo "==> Install complete"
