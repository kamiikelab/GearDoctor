# AGENTS.md

GearDoctor（Dart / Flutter）で作業するエージェント向けの運用ルールです。詳細手順は [`docs/開発と配布.md`](docs/開発と配布.md) を参照してください。ここには「テストとビルドの役割分担」を要点だけ記します。

## テストとビルドの役割分担

| どこ | 何をするか | CI か |
| --- | --- | --- |
| PC（手元） | `flutter test`（単体・ウィジェット） | 同じコマンドを手元で先に回す。機械は手元 |
| GitHub Actions | PUSH / PR のたびに同じ `flutter test` | **これが CI** |
| Codemagic | APK を作る | ビルド。テスト本体ではない |
| 実機 | できた APK を入れて画面確認 | CI ではない |

エミュレータは使いません。画面の最終確認は実機で行います。

## テスト（CI と同じ）

- コマンドは `flutter test`。GitHub Actions の [`.github/workflows/test.yml`](.github/workflows/test.yml) が push / PR で同じ内容を回します。
- 必要なのは Flutter `3.47.1`（stable）と `libsqlite3-dev`（`sqflite_common_ffi` 用）だけ。手元でも `flutter pub get` → `flutter gen-l10n` → `flutter test` の順で CI と同じ結果になります。
- テストに `clang` / `cmake` / `ninja` / `libgtk-3-dev` / `libwebkit2gtk`（＝`flutter run -d linux` 用）は不要です。GitHub Actions にも入れていません。

## ビルド（APK）

- APK は **Codemagic** が作ります。テストとは別工程です。
- 手元で作る場合は `./scripts/build_apk.sh`（版を 0.0.1 上げ、成果物は `build/app/outputs/flutter-apk/app-release.apk`）。据え置きは `./scripts/build_apk.sh --no-bump`。
- APK ビルドには Android SDK + JDK 17 が必要です。テスト用の環境には入れません。

## 画面確認

- 画面の目視は **実機**（Codemagic の APK を入れる）で行います。
- `flutter run -d linux` の Linux デスクトップ窓はスマホ画面ではなく、審査・実機確認の代わりにはなりません。

## Cloud Agent 環境

- Cloud Agent の開発環境は **CI と同じ最小構成**（`flutter test` まで）です。設定は [`.cursor/environment.json`](.cursor/environment.json) と [`.cursor/install.sh`](.cursor/install.sh)。
- `clang` / `cmake` / `ninja` / `libgtk-3-dev` / `libwebkit2gtk` は入れません。APK ビルドと実機確認は上記のとおり Codemagic と実機で行います。

## 版上げ・コミット・プッシュ

- アプリ本体（Flutter／ビルドに入るもの）の修正が終わったときだけ、一度だけ「バージョンを上げてコミットPUSHしますか」と聞きます（[`.cursor/rules/version-commit-push.mdc`](.cursor/rules/version-commit-push.mdc)）。
- 修正中は途中確認せず、最後まで進めます。画面案・ドキュメントだけなら聞きません。
- 「はい」なら `pubspec.yaml` の `+`（ビルド番号）を 1 つ上げてコミットし、`kamiikelab` へ push します。表示版（`1.0.5` など）はユーザーに見せる版を変えるときだけ上げます。
