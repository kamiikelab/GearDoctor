#!/usr/bin/env bash
# Codemagic 用: App Store Connect の最新ビルド番号 +1 を pubspec.yaml の
# ビルド番号（version の +NN 部分）に反映する。iOS の CFBundleVersion は
# FLUTTER_BUILD_NUMBER(=pubspec の +NN) から来るため、これで毎回一意な番号になり
# 「value has already been used」の重複アップロード失敗を防げる。
#
# 使い方: Codemagic のワークフローの「ビルド前スクリプト」で次を実行する。
#   bash scripts/codemagic_next_build_number.sh
#
# 前提:
#   - App Store Connect 連携（API キー）が Codemagic に設定済み（公開に必要なもの）。
#   - 環境変数 APP_STORE_APP_ID に対象アプリの数値 App ID を設定。
#   - codemagic-cli-tools の `app-store-connect` が使える（Codemagic の macOS では既定で利用可）。
#
# 表示版（version の x.y.z 部分）は変更しない。ビルド番号だけを最新+1にする。
set -euo pipefail

if [[ -z "${APP_STORE_APP_ID:-}" ]]; then
  echo "APP_STORE_APP_ID が未設定です。Codemagic の環境変数に設定してください。" >&2
  exit 1
fi

LATEST="$(app-store-connect get-latest-app-store-build-number "$APP_STORE_APP_ID")"
if ! [[ "$LATEST" =~ ^[0-9]+$ ]]; then
  echo "App Store Connect の最新ビルド番号を取得できませんでした: '$LATEST'" >&2
  exit 1
fi
NEXT=$((LATEST + 1))
echo "App Store Connect 最新=$LATEST → 次のビルド番号=$NEXT"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$ROOT/pubspec.yaml" "$NEXT" <<'PY'
import re
import sys

path, nxt = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
new = re.sub(
    r"^(version:\s*\d+\.\d+\.\d+)\+\d+",
    r"\1+" + nxt,
    text,
    count=1,
    flags=re.M,
)
if new == text:
    raise SystemExit("pubspec.yaml の version 行を更新できませんでした。")
open(path, "w", encoding="utf-8").write(new)
print(f"pubspec.yaml のビルド番号を +{nxt} に更新しました。")
PY
