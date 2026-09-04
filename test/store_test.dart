import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gear_doctor/data/app_database.dart';
import 'package:gear_doctor/data/app_repository.dart';
import 'package:gear_doctor/data/seed.dart';
import 'package:gear_doctor/data/strava_secret_vault.dart';
import 'package:gear_doctor/domain/dates.dart';
import 'package:gear_doctor/domain/replacement_csv.dart';
import 'package:gear_doctor/domain/settings_csv.dart';
import 'package:gear_doctor/models/models.dart';
import 'package:gear_doctor/state/app_store.dart';
import 'package:gear_doctor/strava/strava_oauth.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

String roadPart(String catalogId) => partIdOnGear(catalogId, 'g_road');

void main() {
  late Directory dir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('geardoctor_test');
  });

  tearDown(() async {
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  Future<AppStore> openStore() async {
    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
    );
    await store.load();
    return store;
  }

  test('first launch seeds demo parts and display groups', () async {
    final store = await openStore();
    expect(store.parts.length, 18);
    expect(store.groups.length, 5);
    expect(store.cards.map((card) => card.title).toList(), [
      'タイヤ',
      'チェーン',
      'ブレーキパッド',
      'ワイヤー',
      'ブレーキオイル',
      'ディスク',
      'バーテープ',
      'スピードセンサ電池',
      'パワーセンサ電池',
      'リモコン電池',
      '心拍計電池',
      'リヤライト電池',
      'プーリー',
    ]);
    expect(store.selectedGear?.name, 'ロード');
    expect(store.gears.map((gear) => gear.name).toSet(), {
      'ロード',
      'シクロクロス',
      'TTバイク',
    });
    expect(store.usingDemoRides, isTrue);
    expect(store.partById(roadPart('p_battery')), isNull);
    expect(store.partById(roadPart('p_front_oil'))!.cycle, CycleKind.distance);
    expect(store.usedOf(store.partById(roadPart('p_speed_batt'))!), 7);
    expect(
      store.alerts.map((alert) => alert.label).toList(),
      ['タイヤ F', 'ブレーキパッド F'],
    );
  });

  test('demo blocks new parts and CSV import until a real ride is added', () async {
    final store = await openStore();
    final part = Part(
      id: 'p_blocked',
      gearId: 'g_road',
      registeredName: 'ブロック',
      cycle: CycleKind.distance,
      limitMode: LimitMode.recommended,
      recommendedLimit: 3000,
      customLimit: 3000,
      thresholdPct: 80,
      sortOrder: store.nextSortOrder(),
    );
    await expectLater(
      store.savePart(part, isNew: true),
      throwsA(isA<DemoRequiresSyncException>()),
    );
    expect(store.partById('p_blocked'), isNull);

    final parsed = parseReplacementCsv('''
登録名,交換日,メモ
チェーン,2026-06-12,CSV
''');
    final plan = planReplacementImport(
      rows: parsed.rows,
      parts: store.parts,
    );
    await expectLater(
      store.importReplacementPlan(plan),
      throwsA(isA<DemoRequiresSyncException>()),
    );
    expect(
      store.replacementsFor(roadPart('p_chain')).map((item) => formatDate(item.replacedOn)),
      ['2025-11-12'],
    );

    final settingsParsed = parseSettingsCsv('''
$settingsCsvHeader
チェーン,距離,設定,4000,1111,80,,
''');
    final settingsPlan = planSettingsImport(
      rows: settingsParsed.rows,
      parts: store.parts,
    );
    await expectLater(
      store.importSettingsPlan(settingsPlan),
      throwsA(isA<DemoRequiresSyncException>()),
    );
    expect(store.partById(roadPart('p_chain'))!.customLimit, 4000);
  });

  test('existing installs drop battery and convert oil to distance', () async {
    final repo = AppRepository(
      await AppDatabase(overridePath: '${dir.path}/migrate.db').instance,
    );
    await seedDemoData(repo);
    await repo.upsertPart(
      const Part(
        id: 'p_battery',
        gearId: 'g_road',
        registeredName: 'バッテリー',
        cycle: CycleKind.months,
        limitMode: LimitMode.recommended,
        recommendedLimit: 24,
        customLimit: 24,
        thresholdPct: 80,
        sortOrder: 99,
      ),
    );
    final oil = (await repo.loadParts(gearId: 'g_road'))
        .firstWhere((part) => part.id == roadPart('p_front_oil'));
    await repo.upsertPart(
      oil.copyWith(
        cycle: CycleKind.months,
        recommendedLimit: 24,
        customLimit: 24,
      ),
    );

    await ensureMissingDefaultParts(
      repo,
      now: parseDate('2026-08-23'),
      gearId: 'g_road',
    );
    final parts = await repo.loadParts(gearId: 'g_road');
    expect(parts.any((part) => part.id == 'p_battery'), isFalse);
    final updatedOil = parts.firstWhere((part) => part.id == roadPart('p_front_oil'));
    expect(updatedOil.cycle, CycleKind.distance);
    expect(updatedOil.recommendedLimit, 10000);
  });

  test('combine and dissolve only change display', () async {
    final store = await openStore();
    await store.dissolveGroup(groupIdOnGear('grp_tire', 'g_road'));
    expect(store.cards.any((card) => card.title == '前タイヤ'), isTrue);
    expect(store.cards.any((card) => card.title == '後タイヤ'), isTrue);
    expect(store.partById(roadPart('p_front_tire'))!.registeredName, '前タイヤ');

    await store.combineDisplay(
      frontPartId: roadPart('p_front_tire'),
      rearPartId: roadPart('p_rear_tire'),
      displayName: 'タイヤ',
    );
    expect(store.cards.any((card) => card.title == 'タイヤ'), isTrue);
    expect(store.partById(roadPart('p_front_tire'))!.registeredName, '前タイヤ');
  });

  test('replacement date change recalculates usage', () async {
    final store = await openStore();
    final part = store.partById(roadPart('p_chain'))!;
    final before = store.usedOf(part);
    expect(before, greaterThan(0));

    await store.addReplacement(
      partId: part.id,
      replacedOn: parseDate('2026-08-23'),
      memo: '新品',
    );
    expect(store.usedOf(part), 0);
  });

  test('new part first replacement is the oldest ride of the selected gear', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    expect(formatDate(store.partOriginOn), '2023-04-15');
    await store.savePart(
      Part(
        id: 'p_new',
        gearId: 'g_road',
        registeredName: '新品',
        cycle: CycleKind.distance,
        limitMode: LimitMode.recommended,
        recommendedLimit: 3000,
        customLimit: 3000,
        thresholdPct: 80,
        sortOrder: store.nextSortOrder(),
      ),
      isNew: true,
    );
    final first = store.replacementsFor('p_new').single;
    expect(formatDate(first.replacedOn), '2023-04-15');
  });

  test('new part first replacement is today when the selected gear has no rides', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    await store.selectGear('g_cx');
    expect(store.oldestSelectedRideOn, isNull);
    await store.savePart(
      Part(
        id: 'p_cx_only',
        gearId: 'g_cx',
        registeredName: 'シクロクロス用',
        cycle: CycleKind.distance,
        limitMode: LimitMode.recommended,
        recommendedLimit: 3000,
        customLimit: 3000,
        thresholdPct: 80,
        sortOrder: store.nextSortOrder(),
      ),
      isNew: true,
    );
    final first = store.replacementsFor('p_cx_only').single;
    expect(formatDate(first.replacedOn), '2026-08-23');
  });

  test('Strava tokens persist on the device and survive reload', () async {
    final store = await openStore();
    expect(store.settings.stravaConnected, isFalse);
    await store.saveStravaAuth(
      StravaAuthResult(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresAt: DateTime.utc(2030, 1, 1),
        athleteId: '42',
        athleteName: 'Ken Rider',
        bikes: const [Gear(id: 'b1', name: 'Tarmac')],
      ),
    );
    expect(store.settings.stravaConnected, isTrue);
    expect(store.settings.stravaAthleteName, 'Ken Rider');
    expect(store.gears.any((gear) => gear.name == 'Tarmac'), isTrue);
    expect(store.gears.any((gear) => gear.id == 'g_road'), isFalse);
    expect(store.settings.selectedGearId, 'b1');

    final again = await openStore();
    expect(again.settings.stravaAccessToken, 'access-1');
    expect(again.settings.stravaConnected, isTrue);
    await again.disconnectStrava();
    expect(again.settings.stravaConnected, isFalse);
  });

  test('resetToDemo restores seed parts, rides, and clears Strava', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    await store.savePart(
      Part(
        id: 'p_custom',
        gearId: 'g_road',
        registeredName: 'カスタム部品',
        cycle: CycleKind.distance,
        limitMode: LimitMode.recommended,
        recommendedLimit: 3000,
        customLimit: 3000,
        thresholdPct: 80,
        sortOrder: store.nextSortOrder(),
      ),
      isNew: true,
    );
    await store.saveStravaCredentials(clientId: '123', clientSecret: 'secret');
    await store.saveStravaAuth(
      StravaAuthResult(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresAt: DateTime.utc(2030, 1, 1),
        athleteId: '42',
        athleteName: 'Ken Rider',
        bikes: const [Gear(id: 'b1', name: 'Tarmac')],
      ),
    );
    expect(store.partById('p_custom'), isNull);
    expect(store.parts.length, 18);
    expect(store.parts.every((part) => part.gearId == 'b1'), isTrue);
    expect(store.settings.stravaConnected, isTrue);
    expect(store.gears.any((gear) => gear.id == 'b1'), isTrue);

    await store.resetToDemo();
    expect(store.partById('p_custom'), isNull);
    expect(store.parts.length, 18);
    expect(store.usingDemoRides, isTrue);
    expect(store.selectedGear?.name, 'ロード');
    expect(store.settings.stravaConnected, isFalse);
    expect(store.settings.stravaAccessToken, isNull);
    expect(store.settings.stravaClientId, isNull);
    expect(store.gears.any((gear) => gear.id == 'g_road'), isTrue);
    expect(store.gears.any((gear) => gear.id == 'b1'), isFalse);
  });

  test('vault keeps secrets and tokens out of sqlite', () async {
    final vault = MemoryStravaSecretVault();
    final dbPath = '${dir.path}/app.db';
    final store = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
      secretVault: vault,
    );
    await store.load();
    await store.saveStravaCredentials(clientId: '123', clientSecret: 's3cret');
    await store.saveStravaAuth(
      StravaAuthResult(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresAt: DateTime.utc(2030, 1, 1),
        athleteId: '42',
        athleteName: 'Ken Rider',
        bikes: const [Gear(id: 'b1', name: 'Tarmac')],
      ),
    );
    expect(store.settings.stravaClientId, '123');
    expect(await vault.readClientSecret(), 's3cret');
    expect(await vault.readAccessToken(), 'access-1');
    expect(await vault.readRefreshToken(), 'refresh-1');

    final withoutVault = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
    );
    await withoutVault.load();
    expect(withoutVault.settings.stravaClientId, isNull);
    expect(withoutVault.settings.stravaClientSecret, isNull);
    expect(withoutVault.settings.stravaAccessToken, isNull);
    expect(withoutVault.settings.stravaRefreshToken, isNull);

    final withVault = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
      secretVault: vault,
    );
    await withVault.load();
    expect(withVault.settings.stravaClientId, '123');
    expect(withVault.settings.stravaClientSecret, 's3cret');
    expect(withVault.settings.stravaAccessToken, 'access-1');
    expect(withVault.settings.stravaRefreshToken, 'refresh-1');

    await withVault.disconnectStrava();
    expect(await vault.readAccessToken(), isNull);
    expect(await vault.readRefreshToken(), isNull);
    expect(await vault.readClientId(), '123');
    expect(await vault.readClientSecret(), 's3cret');
  });

  test('vault migrates secrets and tokens out of sqlite and reset clears them', () async {
    final dbPath = '${dir.path}/app.db';
    final store = await openStore();
    await store.saveStravaCredentials(clientId: '123', clientSecret: 's3cret');
    await store.saveStravaAuth(
      StravaAuthResult(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresAt: DateTime.utc(2030, 1, 1),
        athleteId: '42',
        athleteName: 'Ken Rider',
        bikes: const [Gear(id: 'b1', name: 'Tarmac')],
      ),
    );
    expect(store.settings.stravaClientSecret, 's3cret');

    final vault = MemoryStravaSecretVault();
    final migrated = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
      secretVault: vault,
    );
    await migrated.load();
    expect(migrated.settings.stravaClientId, '123');
    expect(await vault.readClientSecret(), 's3cret');
    expect(await vault.readAccessToken(), 'access-1');
    expect(await vault.readRefreshToken(), 'refresh-1');

    final leftover = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
    );
    await leftover.load();
    expect(leftover.settings.stravaClientId, isNull);
    expect(leftover.settings.stravaClientSecret, isNull);
    expect(leftover.settings.stravaAccessToken, isNull);
    expect(leftover.settings.stravaRefreshToken, isNull);

    await migrated.resetToDemo();
    expect(migrated.settings.stravaClientId, isNull);
    expect(migrated.settings.stravaAccessToken, isNull);
    expect(await vault.readClientId(), isNull);
    expect(await vault.readClientSecret(), isNull);
    expect(await vault.readAccessToken(), isNull);
    expect(await vault.readRefreshToken(), isNull);
  });

  test('english device locale seeds english registered names', () async {
    final store = AppStore(
      database: AppDatabase(overridePath: '${dir.path}/app.db'),
      now: parseDate('2026-08-23'),
      deviceLocale: 'en',
    );
    await store.load();
    expect(store.cards.map((card) => card.title).toList(), contains('Tires'));
    expect(store.selectedGear?.name, 'Road');
    expect(store.partById(roadPart('p_chain'))!.registeredName, 'Chain');
    expect(
      store.groups.any((group) => group.displayName == 'Tires'),
      isTrue,
    );
  });

  test('resetToDemo writes catalog names for the selected language', () async {
    final store = await openStore();
    expect(store.partById(roadPart('p_chain'))!.registeredName, 'チェーン');
    await store.setLocaleCode('en');
    await store.resetToDemo();
    expect(store.settings.localeCode, 'en');
    expect(store.partById(roadPart('p_chain'))!.registeredName, 'Chain');
    expect(store.cards.any((card) => card.title == 'Tires'), isTrue);
  });

  test('changing sync start deletes rides so coverage can restart', () async {
    final store = await openStore();
    expect(store.rides, isNotEmpty);
    expect(formatDate(store.newestSyncedOn!), '2026-07-15');

    await store.changeSyncStart(parseDate('2024-01-01'));
    expect(store.rides, isEmpty);
    expect(store.newestSyncedOn, isNull);
    expect(formatDate(store.settings.lastSyncFrom!), '2024-01-01');

    final again = await openStore();
    expect(again.rides, isEmpty);
    expect(formatDate(again.settings.lastSyncFrom!), '2024-01-01');
    expect(again.newestSyncedOn, isNull);
  });

  test('same start date does not delete rides', () async {
    final store = await openStore();
    final count = store.rides.length;
    await store.changeSyncStart(parseDate('2025-07-17'));
    expect(store.rides.length, count);
    expect(formatDate(store.newestSyncedOn!), '2026-07-15');
  });

  test('CSV import replaces history for parts in the file', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    expect(
      store.replacementsFor(roadPart('p_chain')).map((item) => formatDate(item.replacedOn)),
      ['2025-11-12'],
    );
    final parsed = parseReplacementCsv('''
登録名,交換日,メモ
チェーン,2026-06-12,CSV
''');
    final plan = planReplacementImport(
      rows: parsed.rows,
      parts: store.parts,
    );
    expect(plan.errors, isEmpty);
    final result = await store.importReplacementPlan(plan);
    expect(result.added, 1);
    expect(result.skippedDuplicates, 0);
    expect(
      store.replacementsFor(roadPart('p_chain')).map((item) => formatDate(item.replacedOn)).toList(),
      ['2026-06-12'],
    );
    expect(
      store.replacementsFor(roadPart('p_front_tire')).any(
            (item) => formatDate(item.replacedOn) == '2023-04-02',
          ),
      isTrue,
    );
  });

  test('replacements, parts, and CSV are per selected gear', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    expect(store.replacementsFor(roadPart('p_chain')), hasLength(1));

    await store.selectGear('g_cx');
    final enduraceChain =
        store.parts.firstWhere((part) => part.registeredName == 'チェーン');
    expect(enduraceChain.id, isNot(roadPart('p_chain')));
    expect(store.replacementsFor(enduraceChain.id), hasLength(1));

    await store.addReplacement(
      partId: enduraceChain.id,
      replacedOn: parseDate('2026-02-01'),
      memo: 'シクロクロス',
    );
    expect(
      store.replacementsFor(enduraceChain.id).map((item) => formatDate(item.replacedOn)),
      ['2026-02-01', '2023-04-15'],
    );

    await store.selectGear('g_road');
    expect(
      store.replacementsFor(roadPart('p_chain')).map((item) => formatDate(item.replacedOn)),
      ['2025-11-12'],
    );

    await store.selectGear('g_cx');
    final parsed = parseReplacementCsv('''
登録名,交換日,メモ
チェーン,2026-04-01,CSV
''');
    final plan = planReplacementImport(
      rows: parsed.rows,
      parts: store.parts,
    );
    await store.importReplacementPlan(plan);
    expect(
      store.replacementsFor(enduraceChain.id).map((item) => formatDate(item.replacedOn)),
      ['2026-04-01'],
    );

    await store.selectGear('g_road');
    expect(
      store.replacementsFor(roadPart('p_chain')).map((item) => formatDate(item.replacedOn)),
      ['2025-11-12'],
    );
  });

  test('editing a part on one gear does not change the same name on another', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    final aeroadChain = store.partById(roadPart('p_chain'))!;
    await store.savePart(
      aeroadChain.copyWith(customLimit: 1111, limitMode: LimitMode.custom),
      isNew: false,
    );
    expect(store.partById(roadPart('p_chain'))!.customLimit, 1111);

    await store.selectGear('g_cx');
    final enduraceChain =
        store.parts.firstWhere((part) => part.registeredName == 'チェーン');
    expect(enduraceChain.customLimit, 4000);
    expect(enduraceChain.limitMode, LimitMode.recommended);
  });

  test('settings CSV updates, creates, and regroups only the selected gear', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    final parsed = parseSettingsCsv('''
$settingsCsvHeader
チェーン,距離,設定,4000,2222,70,,
カスタム部品,月,推奨,12,12,80,,
前タイヤ,距離,推奨,6000,5000,80,タイヤ,F
後タイヤ,距離,推奨,6000,5000,80,タイヤ,R
''');
    expect(parsed.errors, isEmpty);
    final plan = planSettingsImport(rows: parsed.rows, parts: store.parts);
    expect(plan.errors, isEmpty);
    final result = await store.importSettingsPlan(plan);
    expect(result.updated, 3);
    expect(result.created, 1);
    expect(result.grouped, 1);
    expect(store.partById(roadPart('p_chain'))!.customLimit, 2222);
    expect(store.partById(roadPart('p_chain'))!.thresholdPct, 70);
    expect(store.parts.any((part) => part.registeredName == 'カスタム部品'), isTrue);
    expect(store.groupOf(roadPart('p_front_tire'))!.displayName, 'タイヤ');
    expect(
      store.replacementsFor(roadPart('p_chain')).map((item) => formatDate(item.replacedOn)),
      ['2025-11-12'],
    );

    await store.selectGear('g_cx');
    final enduraceChain =
        store.parts.firstWhere((part) => part.registeredName == 'チェーン');
    expect(enduraceChain.customLimit, 4000);
    expect(store.parts.any((part) => part.registeredName == 'カスタム部品'), isFalse);
  });

  test('syncForward stores bike rides and advances fetched-through', () async {
    final store = await openStore();
    await store.saveStravaAuth(
      StravaAuthResult(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresAt: DateTime.utc(2030, 1, 1),
        athleteId: '42',
        athleteName: 'Ken Rider',
        bikes: const [Gear(id: 'b1', name: 'Tarmac')],
      ),
    );

    var activityCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/api/v3/athlete') {
        return http.Response(
          '{"id":42,"bikes":[{"id":"b1","name":"Tarmac"}]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/v3/athlete/activities') {
        activityCalls += 1;
        expect(request.headers['Authorization'], 'Bearer access-1');
        if (activityCalls == 1) {
          return http.Response(
            jsonEncode([
              {
                'id': 99,
                'sport_type': 'Ride',
                'distance': 15000,
                'start_date': '2025-08-01T08:00:00Z',
                'gear_id': 'b1',
              },
              {
                'id': 100,
                'sport_type': 'Run',
                'distance': 5000,
                'start_date': '2025-08-02T08:00:00Z',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      fail('unexpected ${request.method} ${request.url}');
    });

    final first = await store.syncForward(months: 1, client: client);
    expect(formatDate(first.from), '2025-07-17');
    expect(formatDate(first.to), '2025-08-17');
    expect(first.savedCount, 1);
    expect(formatDate(first.newestRideOn!), '2025-08-01');
    expect(store.rides.single.id, '99');
    expect(store.rides.single.distanceKm, 15);
    expect(formatDate(store.settings.lastSyncAt!), '2025-08-17');
    expect(store.rides.any((ride) => ride.id.startsWith('ride_')), isFalse);
    expect(store.usingDemoRides, isFalse);

    final second = await store.syncForward(months: 1, client: client);
    expect(formatDate(second.from), '2025-08-17');
    expect(formatDate(second.to), '2025-09-17');
    expect(second.savedCount, 0);
    expect(formatDate(store.settings.lastSyncAt!), '2025-09-17');
    expect(formatDate(store.newestSyncedOn!), '2025-08-01');
  });

  test('manual ride replaces demo rides and does not mark Strava connected', () async {
    final store = await openStore();
    expect(store.usingDemoRides, isTrue);
    expect(store.settings.stravaConnected, isFalse);

    await store.addManualRide(
      on: parseDate('2026-08-23'),
      distanceKm: 32,
    );

    expect(store.usingDemoRides, isFalse);
    expect(store.settings.stravaConnected, isFalse);
    expect(store.settings.lastSyncFrom, isNull);
    expect(store.rides.length, 1);
    expect(store.rides.single.id, startsWith('manual_'));
    expect(store.rides.single.gearId, 'g_road');
    expect(store.rides.single.distanceKm, 32);
    expect(formatDate(store.rides.single.startedOn), '2026-08-23');
    await store.savePart(
      Part(
        id: 'p_after_ride',
        gearId: 'g_road',
        registeredName: 'ライト',
        cycle: CycleKind.months,
        limitMode: LimitMode.recommended,
        recommendedLimit: 12,
        customLimit: 12,
        thresholdPct: 80,
        sortOrder: store.nextSortOrder(),
      ),
      isNew: true,
    );
    expect(store.partById('p_after_ride'), isNotNull);
  });

  test('manual ride can be updated and deleted', () async {
    final store = await openStore();
    await store.addManualRide(on: parseDate('2026-08-23'), distanceKm: 32);
    expect(store.settings.rideSource, RideSource.manual);
    final id = store.rides.single.id;

    await store.updateManualRide(
      id: id,
      on: parseDate('2026-08-20'),
      distanceKm: 18,
    );
    expect(store.rides.single.distanceKm, 18);
    expect(formatDate(store.rides.single.startedOn), '2026-08-20');

    await store.deleteManualRide(id);
    expect(store.rides, isEmpty);
    expect(store.settings.rideSource, RideSource.manual);
  });

  test('syncForward after a manual ride deletes hand-entered rides', () async {
    final store = await openStore();
    await store.addGear('My Bike');
    await store.addManualRide(on: parseDate('2026-08-23'), distanceKm: 32);
    expect(store.rides.single.gearId, startsWith('g_'));
    await store.saveStravaAuth(
      StravaAuthResult(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        expiresAt: DateTime.utc(2030, 1, 1),
        athleteId: '42',
        athleteName: 'Ken Rider',
        bikes: const [Gear(id: 'b1', name: 'Tarmac')],
      ),
    );
    await store.changeSyncStart(parseDate('2025-07-17'));
    expect(store.rides.single.id, startsWith('manual_'));

    final client = MockClient((request) async {
      if (request.url.path == '/api/v3/athlete') {
        return http.Response(
          '{"id":42,"bikes":[{"id":"b1","name":"Tarmac"}]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/v3/athlete/activities') {
        return http.Response(
          jsonEncode([
            {
              'id': 99,
              'sport_type': 'Ride',
              'distance': 15000,
              'start_date': '2025-08-01T08:00:00Z',
              'gear_id': 'b1',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      fail('unexpected ${request.method} ${request.url}');
    });

    await store.syncForward(months: 1, client: client);
    expect(store.rides.any((ride) => isManualRideId(ride.id)), isFalse);
    expect(store.rides.single.id, '99');
    expect(store.settings.rideSource, RideSource.strava);
    await expectLater(
      store.addManualRide(on: parseDate('2026-08-24'), distanceKm: 10),
      throwsStateError,
    );
  });

  test('switchToManualRides deletes Strava rides', () async {
    final store = await openStore();
    await store.convertDemoRidesForTest();
    expect(store.settings.rideSource, RideSource.strava);
    expect(store.rides, isNotEmpty);

    await store.switchToManualRides();
    expect(store.settings.rideSource, RideSource.manual);
    expect(store.rides, isEmpty);
    expect(store.settings.lastSyncFrom, isNull);

    await store.addManualRide(on: parseDate('2026-08-23'), distanceKm: 12);
    expect(store.rides.single.distanceKm, 12);
  });

  test('mixed rides backfill keeps manuals and drops Strava', () async {
    final store = await openStore();
    await store.addManualRide(on: parseDate('2026-08-23'), distanceKm: 32);
    final db = await AppDatabase(overridePath: '${dir.path}/app.db').instance;
    final repo = AppRepository(db);
    await repo.upsertRide(
      Ride(
        id: '99',
        gearId: 'g_road',
        startedOn: parseDate('2026-08-01'),
        distanceKm: 15,
      ),
    );
    await repo.saveSettings(store.settings.copyWith(clearRideSource: true));

    final again = await openStore();
    expect(again.settings.rideSource, RideSource.manual);
    expect(again.rides.every((ride) => isManualRideId(ride.id)), isTrue);
    expect(again.rides.any((ride) => ride.id == '99'), isFalse);
  });

  test('addGear creates a named bike with default parts', () async {
    final store = await openStore();
    await store.addGear('My Bike');
    expect(store.selectedGear?.name, 'My Bike');
    expect(store.selectedGear!.id, startsWith('g_'));
    expect(isDemoGearId(store.selectedGear!.id), isFalse);
    expect(store.parts.length, 18);
  });

  test('demo blocks deleting parts until a real ride is added', () async {
    final store = await openStore();
    final chainId = roadPart('p_chain');
    await expectLater(
      store.deletePart(chainId),
      throwsA(isA<DemoRequiresSyncException>()),
    );
    expect(store.partById(chainId), isNotNull);
  });

  test('hand-added and demo bikes can be deleted during demo, including the last', () async {
    final store = await openStore();
    expect(store.usingDemoRides, isTrue);
    expect(store.gears.map((gear) => gear.id).toSet(), {
      'g_road',
      'g_cx',
      'g_tt',
    });

    await store.deleteGear('g_cx');
    expect(store.gears.map((gear) => gear.id), isNot(contains('g_cx')));
    expect(store.usingDemoRides, isTrue);
    expect(store.selectedGear?.id, 'g_road');

    await store.deleteGear('g_tt');
    await store.deleteGear('g_road');
    expect(store.gears, isEmpty);
    expect(store.selectedGear, isNull);
    expect(store.parts, isEmpty);
    expect(store.settings.selectedGearId, isNull);

    await store.addGear('Solo');
    expect(store.selectedGear?.name, 'Solo');
    expect(store.parts.length, 18);
  });

  test('Strava bikes cannot be deleted from the gear screen', () async {
    final database = AppDatabase(overridePath: '${dir.path}/app.db');
    final store = AppStore(
      database: database,
      now: parseDate('2026-08-23'),
    );
    await store.load();
    final db = await database.instance;
    await db.insert('gears', {'id': 'b1', 'name': 'Tarmac'});
    await store.refresh();
    await store.selectGear('b1');
    await expectLater(
      store.deleteGear('b1'),
      throwsA(isA<StateError>()),
    );
    expect(store.gears.any((gear) => gear.id == 'b1'), isTrue);
  });

  test('deleted catalog parts stay gone after reload, including the initial 18', () async {
    final dbPath = '${dir.path}/app.db';
    final database = AppDatabase(overridePath: dbPath);
    final store = AppStore(
      database: database,
      now: parseDate('2026-08-23'),
    );
    await store.load();
    await store.convertDemoRidesForTest();
    for (final catalog in defaultParts()) {
      await store.deletePart(partIdOnGear(catalog.id, 'g_road'));
    }
    expect(store.parts, isEmpty);
    expect(store.groups, isEmpty);

    await database.close();
    final reopened = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
    );
    await reopened.load();
    await reopened.selectGear('g_road');
    expect(reopened.parts, isEmpty);
    expect(reopened.partById(roadPart('p_chain')), isNull);
    expect(reopened.gears.any((gear) => gear.id == 'g_road'), isTrue);
  });

  test('deleting the last bike does not reseed demo data on launch', () async {
    final dbPath = '${dir.path}/app.db';
    final database = AppDatabase(overridePath: dbPath);
    final store = AppStore(
      database: database,
      now: parseDate('2026-08-23'),
    );
    await store.load();
    for (final id in ['g_cx', 'g_tt', 'g_road']) {
      await store.deleteGear(id);
    }
    expect(store.gears, isEmpty);
    await database.close();

    final reopened = AppStore(
      database: AppDatabase(overridePath: dbPath),
      now: parseDate('2026-08-23'),
    );
    await reopened.load();
    expect(reopened.gears, isEmpty);
    expect(reopened.selectedGear, isNull);
    expect(reopened.parts, isEmpty);
  });
}
