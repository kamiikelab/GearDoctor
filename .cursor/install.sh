#!/usr/bin/env bash
# Cloud Agent install: prepare the GearDoctor Flutter dev environment.
# Idempotent: safe to run repeatedly and against a cached snapshot.
set -euo pipefail

FLUTTER_VERSION="3.47.1"
FLUTTER_DIR="$HOME/flutter"

echo "==> Installing system packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
# Toolchain for `flutter test` (SQLite) and `flutter run/build -d linux`
# (clang/cmake/ninja/gtk), plus CJK fonts and the webkit runtime used by the
# flutter_web_auth_2 / desktop_webview_window plugin.
sudo apt-get install -y --no-install-recommends \
  git curl unzip xz-utils \
  clang cmake ninja-build pkg-config \
  g++ libstdc++-14-dev \
  libgtk-3-dev libsqlite3-dev \
  libwebkit2gtk-4.1-dev \
  xdg-user-dirs \
  fonts-noto-cjk

# path_provider (getApplicationDocumentsDirectory) resolves the Documents
# folder via the `xdg-user-dir` command; make sure the standard XDG user
# directories exist so the app can create its SQLite database on Linux.
xdg-user-dirs-update || true
mkdir -p "$(xdg-user-dir DOCUMENTS 2>/dev/null || echo "$HOME/Documents")"

echo "==> pkg-config shim: webkit2gtk-4.0 -> 4.1 (Ubuntu 24.04 ships only 4.1)"
# desktop_webview_window 0.3.0 asks pkg-config for webkit2gtk-4.0, which Ubuntu
# 24.04 no longer provides. The 4.1 API is compatible for this plugin, so expose
# 4.0 module names that resolve to the installed 4.1 libraries and headers.
PC_DIR="/usr/lib/x86_64-linux-gnu/pkgconfig"
for m in webkit2gtk javascriptcoregtk webkit2gtk-web-extension; do
  if [ -f "$PC_DIR/${m}-4.1.pc" ]; then
    sudo cp -f "$PC_DIR/${m}-4.1.pc" "$PC_DIR/${m}-4.0.pc"
  fi
done

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
flutter config --enable-linux-desktop --no-analytics >/dev/null
flutter --version

echo "==> Resolving project dependencies"
cd "$(dirname "$0")/.."
flutter pub get
flutter gen-l10n

echo "==> Precaching Linux desktop artifacts"
flutter precache --linux

echo "==> Install complete"
