import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gear_doctor/app.dart';
import 'package:gear_doctor/app_version.dart';
import 'package:gear_doctor/data/app_database.dart';
import 'package:gear_doctor/data/seed.dart';
import 'package:gear_doctor/domain/dates.dart';
import 'package:gear_doctor/screens/add_gear_screen.dart';
import 'package:gear_doctor/screens/edit_part_screen.dart';
import 'package:gear_doctor/screens/gear_screen.dart';
import 'package:gear_doctor/screens/home_screen.dart';
import 'package:gear_doctor/screens/part_detail_screen.dart';
import 'package:gear_doctor/screens/settings_screen.dart';
import 'package:gear_doctor/screens/ride_history_screen.dart';
import 'package:gear_doctor/screens/sync_screen.dart';
import 'package:gear_doctor/state/app_store.dart';
import 'package:gear_doctor/widgets/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n_harness.dart';

void main() {
  late Directory dir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('geardoctor_widget');
  });

  tearDown(() async {
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  testWidgets('home shows grouped tires and the add-ride button', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: HomeScreen(store: store)));

    expect(find.text('GearDoctor'), findsOneWidget);
    expect(
      find.textContaining('デモを解除するには走行を追加します'),
      findsOneWidget,
    );
    expect(find.text('タイヤ'), findsOneWidget);
    expect(find.text('チェーン'), findsOneWidget);
    expect(find.textContaining(' / '), findsWidgets);
    expect(find.textContaining('推奨'), findsWidgets);
    expect(find.text('走行を追加'), findsOneWidget);
    expect(find.text('しきい値 2件'), findsOneWidget);
    expect(find.text('タイヤ F'), findsOneWidget);
    expect(find.text('ブレーキパッド F'), findsOneWidget);
    expect(find.textContaining('ギア: ロード（デモ）'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'ギア: ロード（デモ）'),
      findsOneWidget,
    );
    expect(find.text('走行 2023-04-15〜'), findsOneWidget);
    expect(find.text('2026-07-15（デモ）'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(InfoPanel),
      ),
      findsOneWidget,
    );
    final homeScheme = Theme.of(tester.element(find.byType(HomeScreen))).colorScheme;
    final homePanelFill = tester
        .widget<DecoratedBox>(
          find.descendant(
            of: find.descendant(
              of: find.byType(HomeScreen),
              matching: find.byType(InfoPanel),
            ),
            matching: find.byType(DecoratedBox),
          ).first,
        )
        .decoration as BoxDecoration;
    expect(homePanelFill.color, homeScheme.surfaceContainerLow);
    expect(homePanelFill.border, isNull);
    expect(homePanelFill.color, isNot(homeScheme.surfaceContainerHighest));

    await tester.tap(find.textContaining('ギア: ロード（デモ）'));
    await tester.pumpAndSettle();
    expect(find.text('自転車を追加'), findsOneWidget);
    expect(find.text('自転車を削除'), findsOneWidget);
    expect(find.text('部品を追加'), findsOneWidget);
    expect(find.text('交換記録の CSV'), findsOneWidget);
    expect(find.text('部品登録の CSV'), findsOneWidget);
    expect(find.text('部品の表示をまとめる / 分ける'), findsOneWidget);

    await tester.tap(find.text('部品を追加'));
    await tester.pumpAndSettle();
    expect(find.text('先に走行を追加してください'), findsOneWidget);
    expect(
      find.text('デモのあいだは部品の追加・削除と CSV は使えません。'),
      findsWidgets,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('交換記録の CSV'));
    await tester.pumpAndSettle();
    expect(find.text('先に走行を追加してください'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('部品登録の CSV'));
    await tester.pumpAndSettle();
    expect(find.text('先に走行を追加してください'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('走行を追加'));
    await tester.pumpAndSettle();
    expect(find.text('手入力'), findsOneWidget);
    expect(find.text('ギア'), findsOneWidget);
    expect(find.text('ロード'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SyncScreen),
        matching: find.byType(InfoPanel),
      ),
      findsNWidgets(2),
    );
    expect(find.text('記録する'), findsOneWidget);
    expect(find.text('Strava から取り込む'), findsOneWidget);
    expect(find.textContaining('連携は任意です'), findsOneWidget);
    expect(find.text('Strava 連携'), findsOneWidget);
    expect(find.text('前回から1年取り込む'), findsOneWidget);
    expect(find.text('Strava開始日を変更'), findsOneWidget);
    expect(find.text('Stravaの取得済み範囲'), findsOneWidget);
    expect(find.text('2025-07-17〜—'), findsOneWidget);
    expect(find.text('このギアの走行'), findsNothing);
  });

  testWidgets('manual rides can be listed, edited, and deleted', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);
    await tester.runAsync(
      () => store.addManualRide(on: parseDate('2026-07-01'), distanceKm: 18),
    );
    await tester.runAsync(
      () => store.addManualRide(on: parseDate('2026-08-23'), distanceKm: 32),
    );

    await tester.pumpWidget(l10nApp(home: SyncScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('手入力'), findsOneWidget);
    expect(find.text('記録する'), findsOneWidget);
    expect(find.text('Strava から取り込む'), findsOneWidget);
    expect(find.text('走行を確認'), findsOneWidget);
    expect(find.textContaining('連携は任意です'), findsOneWidget);

    await tester.tap(find.text('走行を確認'));
    await tester.pumpAndSettle();
    expect(find.text('このギアの走行'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RideHistoryScreen),
        matching: find.byType(InfoPanel),
      ),
      findsOneWidget,
    );
    expect(find.text('種類'), findsOneWidget);
    expect(find.text('手入力'), findsWidgets);
    expect(find.text('2026-08-23'), findsOneWidget);
    expect(find.text('2026-07-01'), findsOneWidget);
    expect(find.text('32 km'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('2026-08-23')).dy,
      lessThan(tester.getTopLeft(find.text('2026-07-01')).dy),
    );

    await tester.tap(find.text('2026-08-23'));
    await tester.pumpAndSettle();
    expect(find.text('走行を編集'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('この走行を削除'), findsOneWidget);

    await tester.tap(find.text('この走行を削除'));
    await tester.pumpAndSettle();
    expect(find.text('この走行を消しますか？'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'キャンセル'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'キャンセル'));
    await tester.pumpAndSettle();
    expect(find.text('このギアの走行'), findsOneWidget);
    for (final ride in List.of(store.rides)) {
      await tester.runAsync(() => store.deleteManualRide(ride.id));
    }
    await tester.pumpAndSettle();
    expect(store.rides, isEmpty);
    expect(find.text('このギアの走行はまだありません。'), findsOneWidget);
  });

  testWidgets('imported rides stay view-only and the hand-entry form stays', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);
    await tester.runAsync(store.convertDemoRidesForTest);

    await tester.pumpWidget(l10nApp(home: SyncScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('手入力'), findsOneWidget);
    expect(find.text('記録する'), findsOneWidget);
    expect(find.text('Strava から取り込む'), findsOneWidget);
    expect(find.text('走行を確認'), findsOneWidget);
    expect(find.text('手入力に切り替える'), findsNothing);

    await tester.tap(find.text('走行を確認'));
    await tester.pumpAndSettle();
    expect(find.text('このギアの走行'), findsOneWidget);
    expect(find.text('Strava'), findsWidgets);
    expect(find.text('この走行を削除'), findsNothing);
    expect(find.text('保存'), findsNothing);
  });

  testWidgets('home gear button uses text width on a phone-sized screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);
    await tester.pumpWidget(l10nApp(home: HomeScreen(store: store)));
    await tester.pumpAndSettle();

    final button = find.widgetWithText(OutlinedButton, 'ギア: ロード（デモ）');
    expect(button, findsOneWidget);
    expect(tester.getSize(button).width, lessThan(200));
    expect(tester.getSize(button).width, greaterThan(120));
    expect(find.text('走行 2023-04-15〜'), findsOneWidget);
    expect(find.text('2026-07-15（デモ）'), findsOneWidget);
  });

  testWidgets('part detail shows replacement history under the replace button', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(
      l10nApp(
        home: PartDetailScreen(
          store: store,
          partId: partIdOnGear('p_chain', 'g_road'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(' / '), findsOneWidget);
    expect(find.textContaining('推奨'), findsOneWidget);
    expect(find.text('交換した'), findsOneWidget);
    expect(find.text('過去の交換記録'), findsOneWidget);
    expect(find.text('ギアの走行距離'), findsOneWidget);
    expect(find.text('交換日'), findsOneWidget);
    expect(find.text('コメント'), findsOneWidget);
    expect(find.text('2025-11-12'), findsOneWidget);
    expect(find.text('9,920km（デモ）'), findsOneWidget);
    expect(find.text('12,800km（デモ）（今日）'), findsOneWidget);
  });

  testWidgets('replacement history is newest first', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(
      l10nApp(
        home: PartDetailScreen(
          store: store,
          partId: partIdOnGear('p_front_tire', 'g_road'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2025-05-01'), findsOneWidget);
    expect(find.text('2024-01-15'), findsOneWidget);
    expect(find.text('2023-04-02'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('2025-05-01')).dy,
      lessThan(tester.getTopLeft(find.text('2024-01-15')).dy),
    );
    expect(
      tester.getTopLeft(find.text('2024-01-15')).dy,
      lessThan(tester.getTopLeft(find.text('2023-04-02')).dy),
    );
  });

  testWidgets('settings reset shows a confirmation dialog', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('走行を追加'), findsNothing);
    expect(find.text('ギア'), findsNothing);
    expect(find.text(appVersionLabel), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    expect(find.text('部品を追加'), findsNothing);
    expect(find.text('交換記録の CSV'), findsNothing);
    await tester.tap(find.text('初期状態に戻す'));
    await tester.pumpAndSettle();
    expect(find.text('初期状態に戻しますか？'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(store.parts.length, 18);
  });

  testWidgets('settings can hide Strava help copy', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('ユーザー説明'), findsOneWidget);
    expect(find.text('あり'), findsOneWidget);
    expect(find.text('なし'), findsOneWidget);
    expect(find.textContaining('初回と同じデモ状態に戻します'), findsOneWidget);

    await tester.runAsync(() => store.setShowUserHelp(false));
    await tester.pumpAndSettle();
    expect(store.settings.showUserHelp, isFalse);
    expect(find.textContaining('初回と同じデモ状態に戻します'), findsNothing);

    await tester.pumpWidget(l10nApp(home: SyncScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('Strava から取り込む'), findsOneWidget);
    expect(find.text('Stravaの取得済み範囲'), findsOneWidget);
    expect(find.textContaining('連携は任意です'), findsNothing);
    expect(
      find.textContaining('Strava開始日を変えると、取り込んだ走行は消えます'),
      findsNothing,
    );
    expect(find.text('前回から1年取り込む'), findsOneWidget);
    expect(find.text('Strava 連携'), findsOneWidget);

    await tester.pumpWidget(
      l10nApp(
        home: EditPartScreen(
          store: store,
          partId: partIdOnGear('p_bar_tape', 'g_road'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('名前から自動で決まります。'), findsNothing);
    expect(find.text('ホームに出す名前。前と後ろは別々に登録します。'), findsNothing);

    await tester.pumpWidget(l10nApp(home: GearScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Strava から取った自転車も'), findsNothing);

    await tester.pumpWidget(
      l10nApp(
        home: PartDetailScreen(
          store: store,
          partId: partIdOnGear('p_chain', 'g_road'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('行をタップして日付'), findsNothing);
  });

  testWidgets('home add-ride opens Strava connect, gear button opens gear', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: HomeScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('Strava 連携'), findsNothing);
    await tester.tap(find.text('走行を追加'));
    await tester.pumpAndSettle();
    expect(find.textContaining('連携は任意です'), findsOneWidget);
    await tester.tap(find.text('Strava 連携'));
    await tester.pumpAndSettle();
    expect(find.text('連携を解除'), findsOneWidget);
    expect(find.text('Strava 連携は任意です。'), findsOneWidget);
    expect(find.text('連携方法'), findsOneWidget);
    expect(find.textContaining('Strava の API 設定でアプリを作る'), findsOneWidget);
    expect(find.textContaining('このアプリでは Access Token は使いません'), findsOneWidget);
    expect(find.textContaining('スマホでは許可するとアプリに戻ります'), findsOneWidget);
    expect(find.textContaining('Chrome が自動で開きます'), findsOneWidget);
    expect(find.textContaining('その画面を閉じることが必須です'), findsOneWidget);
    expect(find.textContaining('連携ボタンが緑に戻り「連携済み」になれば成功です'), findsOneWidget);
    expect(find.textContaining('Chrome が自動で開かないとき'), findsOneWidget);
    expect(find.textContaining('許可用 URL をコピー'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'ギア: ロード（デモ）'));
    await tester.pumpAndSettle();
    expect(find.text('部品を追加'), findsOneWidget);
    expect(find.text('交換記録の CSV'), findsOneWidget);
  });

  testWidgets('changing cycle resets custom limit to the new recommended value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(
      l10nApp(
        home: EditPartScreen(
          store: store,
          partId: partIdOnGear('p_bar_tape', 'g_road'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('推奨  5,000 km'), findsOneWidget);
    expect(find.text('名前から自動で決まります。'), findsOneWidget);
    expect(find.textContaining('設定  5000 km'), findsOneWidget);

    await tester.tap(find.text('月'));
    await tester.pumpAndSettle();
    expect(find.textContaining('推奨  24 か月'), findsOneWidget);
    expect(find.textContaining('設定  24 か月'), findsOneWidget);
    expect(find.textContaining('5,000'), findsNothing);
    expect(find.textContaining('5000'), findsNothing);
  });

  testWidgets('edit part offers delete, blocked during demo', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(
      l10nApp(
        home: EditPartScreen(
          store: store,
          partId: partIdOnGear('p_bar_tape', 'g_road'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('この部品を削除'), findsOneWidget);

    await tester.tap(find.text('この部品を削除'));
    await tester.pumpAndSettle();
    expect(find.text('先に走行を追加してください'), findsOneWidget);
    expect(
      find.text('デモのあいだは部品の追加・削除と CSV は使えません。'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(store.partById(partIdOnGear('p_bar_tape', 'g_road')), isNotNull);
  });

  testWidgets('gear screen confirms bike delete', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: GearScreen(store: store)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('自転車を削除'));
    await tester.pumpAndSettle();
    expect(find.text('この自転車を消しますか？'), findsOneWidget);
    expect(find.textContaining('ロード の部品、交換記録、走行も消えます。'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(store.gears.length, 3);
  });

  testWidgets('settings language picker switches the app to English', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);
    await tester.runAsync(() => store.setLocaleCode('ja'));

    await tester.pumpWidget(GearDoctorApp(store: store));
    await tester.pumpAndSettle();
    expect(find.text('設定'), findsOneWidget);

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('端末に合わせる'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Match device'), findsOneWidget);
    expect(find.text('Add ride', skipOffstage: false), findsOneWidget);
    expect(find.text('設定'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('タイヤ'), findsOneWidget);
    expect(find.text('チェーン'), findsOneWidget);
    expect(find.text('Tires'), findsNothing);
    await tester.runAsync(() => store.setLocaleCode('en'));
  });

  testWidgets('english catalog is stored when demo is seeded in English', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
      deviceLocale: 'en',
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(
      l10nApp(home: HomeScreen(store: store), locale: const Locale('en')),
    );
    expect(find.text('Tires'), findsOneWidget);
    expect(find.text('Chain'), findsOneWidget);
    expect(find.text('Bar tape'), findsOneWidget);
    expect(
      find.textContaining('Add a ride to leave the demo'),
      findsOneWidget,
    );
    expect(find.text('タイヤ'), findsNothing);
    expect(
      store.partById(partIdOnGear('p_chain', 'g_road'))!.registeredName,
      'Chain',
    );
  });

  testWidgets('empty field hints are small and light', (tester) async {
    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: AddGearScreen(store: store)));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, 'ロード');
    final theme = Theme.of(tester.element(find.byType(TextField)));
    expect(field.decoration?.hintStyle?.color, theme.colorScheme.outline);
    expect(
      field.decoration?.hintStyle?.fontSize,
      theme.textTheme.bodySmall?.fontSize,
    );
  });
}
