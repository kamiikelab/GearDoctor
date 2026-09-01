import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gear_doctor/app.dart';
import 'package:gear_doctor/app_version.dart';
import 'package:gear_doctor/data/app_database.dart';
import 'package:gear_doctor/data/seed.dart';
import 'package:gear_doctor/domain/dates.dart';
import 'package:gear_doctor/screens/edit_part_screen.dart';
import 'package:gear_doctor/screens/home_screen.dart';
import 'package:gear_doctor/screens/part_detail_screen.dart';
import 'package:gear_doctor/screens/settings_screen.dart';
import 'package:gear_doctor/state/app_store.dart';
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

  testWidgets('home shows grouped tires and the sync button', (tester) async {
    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await tester.runAsync(store.load);

    await tester.pumpWidget(l10nApp(home: HomeScreen(store: store)));

    expect(find.text('GearDoctor'), findsOneWidget);
    expect(
      find.textContaining('デモを解除するには Strava を同期します'),
      findsOneWidget,
    );
    expect(find.text('タイヤ'), findsOneWidget);
    expect(find.text('チェーン'), findsOneWidget);
    expect(find.textContaining(' / '), findsWidgets);
    expect(find.textContaining('推奨'), findsWidgets);
    expect(find.text('Strava同期'), findsOneWidget);
    expect(find.text('しきい値 2件'), findsOneWidget);
    expect(find.text('タイヤ F'), findsOneWidget);
    expect(find.text('ブレーキパッド F'), findsOneWidget);
    expect(find.textContaining('ギア: Aeroad（デモ）'), findsOneWidget);
    expect(
      find.textContaining('最終同期 2025-07-17〜2026-07-15（デモ）'),
      findsOneWidget,
    );

    await tester.tap(find.textContaining('ギア: Aeroad（デモ）'));
    await tester.pumpAndSettle();
    expect(find.text('部品を追加'), findsOneWidget);
    expect(find.text('記録の CSV'), findsOneWidget);
    expect(find.text('部品の CSV'), findsOneWidget);
    expect(find.text('表示をまとめる / 分ける'), findsOneWidget);

    await tester.tap(find.text('部品を追加'));
    await tester.pumpAndSettle();
    expect(find.text('先に Strava を同期してください'), findsOneWidget);
    expect(
      find.text('デモのあいだは部品の追加と CSV は使えません。'),
      findsWidgets,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('記録の CSV'));
    await tester.pumpAndSettle();
    expect(find.text('先に Strava を同期してください'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('部品の CSV'));
    await tester.pumpAndSettle();
    expect(find.text('先に Strava を同期してください'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Strava同期'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Strava開始日  2025-07-17（デモ）'), findsOneWidget);
    expect(find.textContaining('何日まで  2026-07-15（デモ）'), findsOneWidget);
    expect(
      find.textContaining('Strava開始日を変えると、取り込んだ走行は消えて初期化されます'),
      findsOneWidget,
    );

    await tester.tap(find.text('Strava開始日を変更'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
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
          partId: partIdOnGear('p_chain', 'g_aeroad'),
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
    expect(find.text('Strava同期'), findsOneWidget);
    expect(find.text('ギア'), findsWidgets);
    expect(find.text(appVersionLabel), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    expect(find.text('部品を追加'), findsNothing);
    expect(find.text('記録の CSV'), findsNothing);
    await tester.tap(find.text('初期状態に戻す'));
    await tester.pumpAndSettle();
    expect(find.text('初期状態に戻しますか？'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(store.parts.length, 18);
  });

  testWidgets('settings opens a dedicated Strava connect screen', (tester) async {
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
    await tester.tap(find.text('Strava 連携'));
    await tester.pumpAndSettle();
    expect(find.text('連携を解除'), findsOneWidget);
    expect(find.text('連携方法'), findsOneWidget);
    expect(find.textContaining('Authorization Callback Domain は 127.0.0.1'), findsOneWidget);
    expect(find.textContaining('このアプリでは Access Token は使いません'), findsOneWidget);
    expect(find.textContaining('スマホでは許可するとアプリに戻ります'), findsOneWidget);
    expect(find.textContaining('Chrome が自動で開きます'), findsOneWidget);
    expect(find.textContaining('その画面を閉じることが必須です'), findsOneWidget);
    expect(find.textContaining('連携ボタンが緑に戻り「連携済み」になれば成功です'), findsOneWidget);
    expect(find.textContaining('Chrome が自動で開かないとき'), findsOneWidget);
    expect(find.textContaining('許可用 URL をコピー'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'ギア'));
    await tester.pumpAndSettle();
    expect(find.text('部品を追加'), findsOneWidget);
    expect(find.text('記録の CSV'), findsOneWidget);
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
          partId: partIdOnGear('p_bar_tape', 'g_aeroad'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('推奨  5,000 km'), findsOneWidget);
    expect(find.textContaining('設定  5000 km'), findsOneWidget);

    await tester.tap(find.text('月'));
    await tester.pumpAndSettle();
    expect(find.textContaining('推奨  24 か月'), findsOneWidget);
    expect(find.textContaining('設定  24 か月'), findsOneWidget);
    expect(find.textContaining('5,000'), findsNothing);
    expect(find.textContaining('5000'), findsNothing);
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
    expect(find.text('Strava sync'), findsOneWidget);
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
      find.textContaining('Sync Strava to leave the demo'),
      findsOneWidget,
    );
    expect(find.text('タイヤ'), findsNothing);
    expect(
      store.partById(partIdOnGear('p_chain', 'g_aeroad'))!.registeredName,
      'Chain',
    );
  });
}
