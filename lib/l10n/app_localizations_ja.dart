// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'GearDoctor';

  @override
  String startupFailed(String error) {
    return '起動に失敗しました\n$error';
  }

  @override
  String get settings => '設定';

  @override
  String get language => '表示言語';

  @override
  String get languageSystem => '端末に合わせる';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get connected => '連携済み';

  @override
  String get notConnected => '未連携';

  @override
  String get stravaHint => '連携すると走行を取れます。手順は次の画面。';

  @override
  String get stravaConnect => 'Strava 連携';

  @override
  String get stravaSync => 'Strava同期';

  @override
  String get gear => 'ギア';

  @override
  String get gearHint => '距離を足す自転車と、そのギアの交換記録です。';

  @override
  String get resetSection => '初期化';

  @override
  String get resetHint => 'Strava の連携と走行、部品の設定と交換記録を消し、初回と同じデモ状態に戻します。';

  @override
  String get resetToDemo => '初期状態に戻す';

  @override
  String get resetConfirmTitle => '初期状態に戻しますか？';

  @override
  String get resetConfirmBody =>
      'Strava の連携と走行、部品の設定と交換記録をすべて消します。\n\n初回起動と同じデモ状態に戻ります。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get resetConfirmAction => '消して戻す';

  @override
  String get resetDone => '初期状態に戻しました。';

  @override
  String get ok => 'OK';

  @override
  String get save => '保存';

  @override
  String get gearUnselected => '未選択';

  @override
  String gearLabel(String name) {
    return 'ギア: $name';
  }

  @override
  String get gearNone => 'ギア: 未選択';

  @override
  String lastSync(String range) {
    return '最終同期 $range';
  }

  @override
  String get notSynced => '未同期';

  @override
  String syncRangeOpen(String from) {
    return '$from〜—';
  }

  @override
  String syncRange(String from, String to) {
    return '$from〜$to';
  }

  @override
  String get demoBanner => 'デモを解除するには Strava を同期します。最初の取得でデモ走行は消えます。';

  @override
  String alertCount(int count) {
    return 'しきい値 $count件';
  }

  @override
  String get demoSuffix => '（デモ）';

  @override
  String get selectedSuffix => '（選択中）';

  @override
  String get demoSelectedSuffix => '（デモ・選択中）';

  @override
  String get todaySuffix => '（今日）';

  @override
  String get unitKm => 'km';

  @override
  String get unitMonths => 'か月';

  @override
  String get limitModeRecommended => '推奨';

  @override
  String get limitModeAuto => '自動';

  @override
  String get limitModeCustom => '設定';

  @override
  String get limitModeAutoFallback => '自動（推奨）';

  @override
  String get statusOk => '余裕';

  @override
  String get statusSoon => 'そろそろ';

  @override
  String get statusOverdue => '交換';

  @override
  String statusLine(String status, int percent) {
    return '$status・$percent％';
  }

  @override
  String statusLineSide(String side, String status, int percent) {
    return '$side：$status・$percent％';
  }

  @override
  String get demoRequiresSyncTitle => '先に Strava を同期してください';

  @override
  String get demoRequiresSyncMessage => 'デモのあいだは部品の追加と CSV は使えません。';

  @override
  String get gearDemoCsvHint => 'デモのあいだは部品の追加と CSV は使えません。先に Strava を同期してください。';

  @override
  String get gearEmptyHint => '先に Strava を同期すると、ここに自転車が並びます。';

  @override
  String get gearBikesHelp =>
      'Strava から取った自転車だけ選べます。部品の追加・設定、交換記録、CSV は選んだギアだけです。初期の部品は同じです。';

  @override
  String get gearSelectHint => '上で自転車を選ぶと、部品の追加と交換記録が使えます。';

  @override
  String get addPart => '部品を追加';

  @override
  String get editPart => '部品を編集';

  @override
  String get recordsCsv => '記録の CSV';

  @override
  String get settingsCsv => '部品の CSV';

  @override
  String get displayGroups => '表示をまとめる / 分ける';

  @override
  String get registeredName => '登録名';

  @override
  String get registeredNameHint => '登録名（前タイヤ、心拍計電池など）';

  @override
  String get registeredNameHelp => 'ホームに出す名前。前と後ろは別々に登録します。';

  @override
  String get firstReplacementNoRide =>
      '最初の交換日は、このギアのいちばん古い走行日です。走行がまだ無いときは今日になります。';

  @override
  String firstReplacementWithRide(String date) {
    return '最初の交換日は、このギアのいちばん古い走行日（$date）です。入力しません。';
  }

  @override
  String get cycle => '交換周期';

  @override
  String get cycleHelp => '距離か月のどちらか。';

  @override
  String get cycleDistance => '距離';

  @override
  String get cycleMonths => '月';

  @override
  String get limit => '交換目安';

  @override
  String limitRecommended(String amount, String unit) {
    return '推奨  $amount $unit';
  }

  @override
  String get limitRecommendedHelp => '名前から自動で決まります。';

  @override
  String get limitAutoEmpty => '自動  —';

  @override
  String limitAuto(String amount, String unit) {
    return '自動  $amount $unit';
  }

  @override
  String get limitAutoHelp => '直近の2回の間隔。毎回計算';

  @override
  String limitCustom(String amount, String unit) {
    return '設定  $amount $unit';
  }

  @override
  String get limitCustomHelp => '自分で入力します。';

  @override
  String get customValue => '設定値';

  @override
  String get threshold => '通知しきい値';

  @override
  String get nameRequired => '登録名を入力してください';

  @override
  String get customLimitInvalid => '設定の目安は 1 以上の数値にしてください';

  @override
  String get thresholdInvalid => 'しきい値は 1 から 100 の整数です';

  @override
  String get selectGearFirstPart => 'ギアを選んでから部品を追加してください';

  @override
  String get partDetail => '部品の詳細';

  @override
  String get partNotFound => '部品が見つかりません';

  @override
  String get afterMonths => '交換後の経過';

  @override
  String get afterDistance => '交換後の走行距離';

  @override
  String thresholdPct(int pct) {
    return 'しきい値 $pct%';
  }

  @override
  String get lastReplacementNone => '最終交換 未記録';

  @override
  String lastReplacement(String date) {
    return '最終交換 $date';
  }

  @override
  String get replaced => '交換した';

  @override
  String get edit => '編集';

  @override
  String get historyTitle => '過去の交換記録';

  @override
  String get historyHint => '行をタップして日付・コメントの修正や削除';

  @override
  String get historyDistanceHeader => 'ギアの走行距離';

  @override
  String get replacedOn => '交換日';

  @override
  String get comment => 'コメント';

  @override
  String get recordReplace => '交換を記録';

  @override
  String get replaceDateHelp => '初期値は今日。記録し忘れのときは、実際に交換した日に直す';

  @override
  String get memo => 'メモ';

  @override
  String get memoHint => '製品名、交換理由など（空でも可）';

  @override
  String get logReplacement => '記録する';

  @override
  String get editRecord => '記録を編集';

  @override
  String get recordNotFound => '記録が見つかりません';

  @override
  String get editRecordHelp => '日付を変えると、その期間の走行距離を数え直す';

  @override
  String get cannotDeleteLastRecord => '最後の記録は削除できません';

  @override
  String get deleteThisRecord => 'この記録を削除';

  @override
  String get connectAgain => '再連携';

  @override
  String get connect => '連携する';

  @override
  String get disconnect => '連携を解除';

  @override
  String get howToConnect => '連携方法';

  @override
  String get clientIdHint => 'Strava のアプリ登録で発行される番号';

  @override
  String get clientSecretHint => 'Strava のアプリ登録で Show すると出る値';

  @override
  String get waitingBrowser =>
      'Chrome に案内が出たら、その画面を必ず閉じてください。閉じると、上の連携ボタンが再び緑になります。アプリが手前に切り替わることはありません。';

  @override
  String get waitingBrowserMobile => 'Strava の許可画面が開きます。許可するとこのアプリに戻ります。';

  @override
  String get browserDidNotOpen =>
      'Chrome が自動では開きませんでした。次の URL をコピーして Chrome で開いてください。';

  @override
  String get copyAuthorizeUrl => '許可用 URL をコピー';

  @override
  String get copiedAuthorizeUrl =>
      '許可用の URL をコピーしました。Chrome のアドレス欄に貼って開いてください。';

  @override
  String get connectStep1 => '1. Strava の API 設定でアプリを作る';

  @override
  String get callbackDomainHelp =>
      'Authorization Callback Domain は 127.0.0.1。http もポートもパスも付けない。この画面の戻り先を自分で開く必要はありません。';

  @override
  String get stravaPaidApi => 'Standard Tier の API は、Strava の有料サブスクが必要です。';

  @override
  String get connectStep2 => '2. Client ID と Client Secret を上に入れる';

  @override
  String get noAccessToken => 'このアプリでは Access Token は使いません。';

  @override
  String get connectStep3 => '3. 「連携する」を押す';

  @override
  String get connectStep3Help =>
      'スマホでは許可するとアプリに戻ります。パソコンでは Chrome が自動で開きます。許可すると 127.0.0.1 に案内が出ます。その画面を閉じることが必須です。閉じないと、連携ボタンは灰色のままです。パソコンではアプリが手前に切り替わることはありません。この画面を見て、連携ボタンが緑に戻り「連携済み」になれば成功です。走行の取得はホームの「Strava同期」から。';

  @override
  String get connectStep4 => '4. Chrome が自動で開かないとき';

  @override
  String get connectStep4Help =>
      '「連携する」のあとに出る「許可用 URL をコピー」を Chrome のアドレス欄に貼って開きます。あとは 3 と同じく、案内の画面を閉じると連携ボタンが緑に戻ります。';

  @override
  String get enterClientIdSecret => 'Client ID と Client Secret を入力してください。';

  @override
  String portBusy(int port) {
    return 'ポート $port を開けませんでした。他のプロセスを終了して、もう一度連携してください。';
  }

  @override
  String tokenSaved(String name) {
    return 'トークンを端末に保存しました（$name）。';
  }

  @override
  String get disconnected => '連携を解除し、トークンを消しました。';

  @override
  String get syncTitle => 'Strava同期';

  @override
  String stravaStartDate(String value) {
    return 'Strava開始日  $value';
  }

  @override
  String untilDate(String value) {
    return '何日まで  $value';
  }

  @override
  String get untilDateHelp => '何日までは、Strava開始日以降で入っているいちばん新しい走行の日です。';

  @override
  String get syncManualHelp => '期間を選んで取得します。自動では取りに行きません。';

  @override
  String get sync3months => '前回から 3 か月';

  @override
  String get sync6months => '前回から 6 か月';

  @override
  String get sync1year => '前回から 1 年';

  @override
  String get changeStartDate => 'Strava開始日を変更';

  @override
  String get specifyStartDate => 'Strava開始日を指定';

  @override
  String get startDateHelp => 'Strava開始日を変えると、取り込んだ走行は消えて初期化されます。新しい日から取り直します。';

  @override
  String get needStartDate => '先にStrava開始日を指定してください。';

  @override
  String get needConnect => '先に Strava 連携の画面から連携してください。';

  @override
  String get changeStartTitle => 'Strava開始日を変えますか？';

  @override
  String get changeStartBody =>
      '途中でStrava開始日だけ変えると、取得に抜けが出ることがあります。\n\nいま入っている走行データをすべて消してから、新しいStrava開始日から取り直します。';

  @override
  String get deleteAndContinue => '消して続ける';

  @override
  String get dataRange => 'データの範囲';

  @override
  String get emDash => '—';

  @override
  String get csvCopyHint => '入力欄に出してコピーします。';

  @override
  String get recordsCsvHint => '登録名,交換日,メモ';

  @override
  String get settingsCsvHint => '登録名,周期,目安,推奨の値,設定の値,しきい値,まとめ,位置';

  @override
  String get exportCurrentRecords => 'いまの記録を書き出す';

  @override
  String get exportCurrentSettings => 'いまの設定を書き出す';

  @override
  String get insertExample => '例を入れる';

  @override
  String get importCsv => 'CSVを取り込み';

  @override
  String get confirm => '確定';

  @override
  String get fixThese => '直せること';

  @override
  String get recordsCsvScope => 'このギアの交換記録だけを出し入れします。他のギアの記録はそのままです。';

  @override
  String get recordsCsvHelp =>
      '部品は増えません。登録名（前タイヤ）で結びます。CSV に出た部品の、このギアの記録は差し替えます。';

  @override
  String get settingsCsvScope => 'このギアの部品設定だけを出し入れします。他のギアはそのままです。';

  @override
  String get settingsCsvHelp =>
      '登録名で結びます。無い登録名は部品を足します。CSV に出た部品の設定とまとめを、このギアだけ差し替えます。交換記録は変わりません。';

  @override
  String get noNewRows => '新しい行はありません。';

  @override
  String replaceCount(int count) {
    return '差し替え $count 件';
  }

  @override
  String partsApplyCount(int count) {
    return '部品 $count 件';
  }

  @override
  String get exportedEmptyRecords => '交換記録がありません。見出しだけ書き出しました。';

  @override
  String exportedCount(int count) {
    return '$count 件を入力欄に出し、コピーしました。';
  }

  @override
  String get exportedEmptySettings => '部品がありません。見出しだけ書き出しました。';

  @override
  String importedSettings(int updated, int created, String groups) {
    return '更新 $updated 件、追加 $created 件$groupsを、このギアに取り込みました。';
  }

  @override
  String importedRecords(int added) {
    return '$added 件取り込みました。このギアの、CSV に出てきた登録名の以前の記録は置き換えました。';
  }

  @override
  String skippedDuplicates(int count) {
    return ' $count 件は CSV 内の重複なので飛ばしました。';
  }

  @override
  String get groupTitle => '表示のまとめ';

  @override
  String get groupHelp => 'ホームでは1行にまとめます。部品そのものは分かれています。';

  @override
  String get groupTogether => 'まとめて表示';

  @override
  String get groupSplit => '分けて表示';

  @override
  String get groupNeedTwo => 'まとめられる部品が足りません。先に登録名で2件追加してください。';

  @override
  String get groupNameHint => 'タイヤ';

  @override
  String groupPreview(String name) {
    return 'ホームは「$name」。左が R、右が F';
  }

  @override
  String get groupNamePlaceholder => '（名前）';

  @override
  String get noGroups => 'まとめ表示はありません。';

  @override
  String get groupToRemove => '解除するまとめ';

  @override
  String get afterSplit => '分かれたあとの表示（登録名）';

  @override
  String get groupSplitHelp => '登録名は変えない。末尾に F/R を付ける合わせこみはしない';

  @override
  String get enterGroupName => 'まとめた名前を入力してください';

  @override
  String get partsNotFound => '部品が見つかりません';

  @override
  String get sameCycleOnly => '同じ交換周期の部品だけをまとめられます';

  @override
  String get selectGroupToSplit => '解除するまとめを選んでください';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client Secret';

  @override
  String get csvLabel => 'CSV';

  @override
  String get csvNeedGear => 'Strava から自転車を取って選ぶと、この画面が使えます。';

  @override
  String skipCsvDuplicatesPreview(int count) {
    return '、CSV 内の重複 $count 件は飛ばす';
  }

  @override
  String groupsCountPreview(int count) {
    return '、まとめ $count 件';
  }

  @override
  String replaceResetHelp(String name, String usage) {
    return '$nameを交換した日付を記録すると、この位置の$usageだけゼロから始まります。';
  }

  @override
  String get usageDistance => '走行距離';

  @override
  String get usageMonths => '経過月';

  @override
  String statusPercent(int percent, String status) {
    return '$percent% · $status';
  }

  @override
  String syncFetchedEmpty(String from, String to) {
    return '$from から $to まで取得しました。この期間に自転車の走行はありませんでした。';
  }

  @override
  String syncFetched(String from, String to, int count, String newest) {
    return '$from から $to まで取得しました。自転車の走行 $count 件。いちばん新しい走行は $newest です。';
  }

  @override
  String get startDateUnchanged => 'Strava開始日は同じです。';

  @override
  String startDateChanged(String date) {
    return 'Strava開始日を $date にしました。走行データは消してあります。ここから取り直してください。';
  }

  @override
  String changeStartConfirm(String date) {
    return 'Strava開始日を $date にします。\n\nStrava開始日から、入っているいちばん新しい走行まで、抜けなく取れている必要があります。途中でStrava開始日だけ変えると、取得に抜けが出ることがあります。\n\nいま入っている走行データをすべて消してから、新しいStrava開始日から取り直します。';
  }

  @override
  String get pickTwoParts => '1. 2つの部品を選ぶ';

  @override
  String get pickFront => '2. どちらが F か';

  @override
  String get groupedNameStep => '3. まとめた名前';

  @override
  String get pickedSuffix => '（選択）';

  @override
  String partIsFront(String name) {
    return '$name が F';
  }

  @override
  String stopGrouping(String name) {
    return '「$name」のまとめ表示をやめます。各カードは登録名で出します。';
  }

  @override
  String get pickTwoAndFront => '2つの部品と、どちらが F かを選んでください';

  @override
  String get waitingForChrome => 'Chrome で Strava の許可を待っています…';

  @override
  String get closeChromeSuccess =>
      'Chrome に案内が出たら、その画面を閉じてください。連携ボタンが緑に戻れば成功です。';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get couldNotOpenBrowser => 'ブラウザを開けませんでした。';
}
