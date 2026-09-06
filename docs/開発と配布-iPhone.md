# 開発と配布（iPhone）

ソースは Android と同じです。**iPhone は App Store（Codemagic → App Store Connect）で出します。** GitHub Releases には載せません。Android は [開発と配布（Android）](開発と配布-Android.md) です。

対象は **iPhone のみ**（iPad 非対応）。最低 iOS は **15.0** です。バンドル ID は `com.kamiikelab.geardoctor` です。

## いまの流れ（全体）

```
修正を main に載せる
  → 必要なら表示版を上げる（1.0.6 など）
  → + だけを 1 上げた PR を出し、ビルド開始の指示でマージする
  → Codemagic で Build（設定はいじらない）
  → IPA が App Store Connect に上がる
  → 処理待ち
  → TestFlight で実機確認
  → 店頭に出すときは、同じビルドをバージョンに付けて審査に提出
```

GitHub の Release やタグでは、この流れは始まりません。Codemagic の設定も、タグ連動にしないでください。

## 版の決め方

`pubspec.yaml` の `version` がそのまま使われます。例: `1.0.6+34`

| どこ | 意味 |
| --- | --- |
| `1.0.6` | 表示版。設定画面と App Store のバージョン |
| `+34` | ビルド番号。App Store Connect の (34) |

- Codemagic は `pubspec.yaml` の `+` をそのまま使う。**Codemagic の設定で番号を足さない**
- 同じ `+` でもう一度ストアへ上げると「value has already been used」で失敗する
- 修正のコミット / PR には `+` を入れない。修正のあと、`+` だけを 1 上げた PR を出す
- その `+1` PR のマージは、Codemagic の Build を始めるときだけ
- 表示版（`1.0.6` など）は、ユーザーに見せる版を変えるときだけ上げる
- 手元の `./scripts/build_apk.sh` は Android 用。iPhone の IPA は作らない

詳細は [版ルール](../.cursor/rules/version-commit-push.mdc) です。

## ビルド（Codemagic）

1. `kamiikelab/main` に、出したいソースと `+` が入っていることを確認する
2. Codemagic で **Build** を押す（設定は変えない）
3. 成功すると IPA が App Store Connect に送られる
4. Connect でビルドの処理が終わるまで待つ（数分〜十数分）

審査中の版があるときは、新しい IPA を上げないでください。差し戻しでバイナリが必要になったときだけ、`+` を上げてから Build します。

エミュレータは使いません。画面確認は TestFlight の実機です。

## App Store Connect での扱い

新しいアプリは作りません。いつも同じ GearDoctor です。

### TestFlight（自分とテスター）

1. 処理が終わったビルド（例: `1.0.6 (34)`）を内部グループに入れる
2. 自分の iPhone の TestFlight から入れる
3. 外部テスターや公開リンクは、その版の **Beta App Review** が通ってから使える
4. Beta 審査と、店頭の App Store 審査は別です

サインイン欄は空です。ログイン機能はありません。

### 店頭（App Store）

1. バージョン番号をバイナリに合わせる（例: `1.0.6`）。未提出なら、既存の版の番号を書き換えてよい
2. その版に、処理済みのビルドを付ける
3. iPhone のスクリーンショットを付ける。iPad と Apple Watch は不要（iPhone 専用のため）
4. 掲載文・年齢制限・App プライバシー・審査メモを埋める
5. **審査用に追加** → **審査に提出**

いまの自動リリースなら、承認後にストアへ出ます。手動リリースにしてあるときだけ、承認後に自分で公開します。

審査メモの要点:

- アカウントもログインもない
- 起動時にデモの自転車と走行がある
- 走行は手入力で確認できる
- Strava は任意。審査では繋がなくてよい

## 審査中にしてはいけないこと

- Codemagic で新しい IPA を上げる
- 同じ `+` のビルドを再提出する
- GitHub Releases に IPA を載せる
- 新しいアプリとして登録し直す

ソースだけを Git で直す（ドキュメントなど）のは、審査中でも構いません。バイナリは変わりません。

## 実機確認

- TestFlight または、公開後は App Store
- デモ解除は、手入力または Strava の最初の実走行
- Strava の手順は [Strava 連携](Strava連携.md)。iPhone では「連携する」のあと、Web を開く確認が出る

## 枝

正本は `kamiikelab/main` です。PC は `main` のまま（始めるとき `git pull`）。Cloud Agent は `main` から枝を切って PR します。
