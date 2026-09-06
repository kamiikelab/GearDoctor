# AGENTS.md

GearDoctor（Dart / Flutter）で作業するエージェント向けの運用ルールです。詳細手順は [`docs/開発と配布.md`](docs/開発と配布.md)（[Android](docs/開発と配布-Android.md) / [iPhone](docs/開発と配布-iPhone.md)）を参照してください。ここには「テストとビルドの役割分担」を要点だけ記します。

## テストとビルドの役割分担

| どこ | 何をするか | CI か |
| --- | --- | --- |
| PC（手元） | `flutter test`（単体・ウィジェット） | 同じコマンドを手元で先に回す。機械は手元 |
| GitHub Actions | PUSH / PR のたびに同じ `flutter test` | **これが CI** |
| Codemagic | iPhone 用の IPA。App Store Connect へ | ビルド。テスト本体ではない |
| GitHub Releases | Android 用の APK を渡す | 配布。App Store にも Play にも送らない |
| 実機 | Android は Releases の APK、iPhone は TestFlight / ストア | CI ではない |

エミュレータは使いません。画面の最終確認は実機で行います。

## テスト（CI と同じ）

- コマンドは `flutter test`。GitHub Actions の [`.github/workflows/test.yml`](.github/workflows/test.yml) が push / PR で同じ内容を回します。
- 必要なのは Flutter `3.47.1`（stable）と `libsqlite3-dev`（`sqflite_common_ffi` 用）だけ。手元でも `flutter pub get` → `flutter gen-l10n` → `flutter test` の順で CI と同じ結果になります。
- テストに `clang` / `cmake` / `ninja` / `libgtk-3-dev` / `libwebkit2gtk`（＝`flutter run -d linux` 用）は不要です。GitHub Actions にも入れていません。

## ビルドと配布（iPhone と Android は別）

- **iPhone** は今までの流れのまま。Codemagic で IPA を作り、App Store Connect（TestFlight / App Store）へ出す。GitHub の Release やタグは Apple に送らない。
- **Android** は GitHub Releases の APK。**Google Play には出さない。** 手元は `./scripts/build_apk.sh`（版を 0.0.1 上げ、成果物は `build/app/outputs/flutter-apk/app-release.apk`）。据え置きは `./scripts/build_apk.sh --no-bump`。できた APK を Releases に付ける。
- APK ビルドには Android SDK + JDK 17 が必要です。テスト用の環境には入れません。
- Codemagic の設定は iPhone 用のまま。Android の Release を出したからといって、Codemagic や App Store の審査は動かさない。

## 画面確認

- Android の目視は **実機**（Releases の APK を入れる）で行います。
- iPhone の目視は TestFlight またはストアのビルドです。
- `flutter run -d linux` の Linux デスクトップ窓はスマホ画面ではなく、審査・実機確認の代わりにはなりません。

## Cloud Agent 環境

- Cloud Agent の開発環境は **CI と同じ最小構成**（`flutter test` まで）です。設定は [`.cursor/environment.json`](.cursor/environment.json) と [`.cursor/install.sh`](.cursor/install.sh)。
- `clang` / `cmake` / `ninja` / `libgtk-3-dev` / `libwebkit2gtk` は入れません。iPhone の IPA は Codemagic、Android の APK は手元と GitHub Releases、実機確認は上記のとおりです。

## 版上げ・コミット・プッシュ

- アプリ本体（Flutter／ビルドに入るもの）の修正が終わったときだけ、一度だけ「バージョンを上げてコミットPUSHしますか」と聞きます（[`.cursor/rules/version-commit-push.mdc`](.cursor/rules/version-commit-push.mdc)）。
- 修正中は途中確認せず、最後まで進めます。画面案・ドキュメント・ルールだけなら聞きません。
- 「はい」なら**修正だけ**を載せます。`pubspec.yaml` の `+` は修正 PR / 修正コミットに入れません。表示版（`1.0.5` など）はユーザーに見せる版を変えるときだけ上げます。
- **修正の PR を1件でも出したら、その直後に `+` だけを 1 上げた PR を出します。** すでに同じ種類のオープンな PR があるときは出しません。マージはユーザーがチャットで指示するまでしません。
