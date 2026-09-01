import 'package:sqflite/sqflite.dart';

import '../domain/dates.dart';
import '../domain/usage.dart';
import '../models/models.dart';
import 'app_repository.dart';

const demoGearIds = {'g_aeroad', 'g_endurace', 'g_grail'};

bool isDemoGearId(String id) => demoGearIds.contains(id);

bool isDemoRideId(String id) => id.startsWith('ride_');

class DemoRequiresSyncException implements Exception {
  const DemoRequiresSyncException();

  static const title = '先に Strava を同期してください';
  static const message = 'デモのあいだは部品の追加と CSV は使えません。';

  @override
  String toString() => '$title。$message';
}

String partIdOnGear(String catalogId, String gearId) => '$catalogId@$gearId';

String groupIdOnGear(String catalogId, String gearId) => '$catalogId@$gearId';

String catalogIdOf(String id) {
  final at = id.indexOf('@');
  return at <= 0 ? id : id.substring(0, at);
}

bool matchesCatalogPart(String partId, String catalogId, String gearId) {
  return partId == catalogId || partId == partIdOnGear(catalogId, gearId);
}

class _CatalogPart {
  const _CatalogPart(
    this.id,
    this.nameJa,
    this.nameEn,
    this.cycle,
    this.recommended,
    this.custom,
    this.order,
  );

  final String id;
  final String nameJa;
  final String nameEn;
  final CycleKind cycle;
  final int recommended;
  final int custom;
  final int order;

  String nameFor(String locale) => locale == 'en' ? nameEn : nameJa;
}

class _CatalogGroup {
  const _CatalogGroup(
    this.id,
    this.nameJa,
    this.nameEn,
    this.frontPartId,
    this.rearPartId,
  );

  final String id;
  final String nameJa;
  final String nameEn;
  final String frontPartId;
  final String rearPartId;

  String nameFor(String locale) => locale == 'en' ? nameEn : nameJa;
}

const _catalogParts = [
  _CatalogPart('p_front_tire', '前タイヤ', 'Front tire', CycleKind.distance, 6000, 5000, 0),
  _CatalogPart('p_rear_tire', '後タイヤ', 'Rear tire', CycleKind.distance, 6000, 5000, 1),
  _CatalogPart('p_chain', 'チェーン', 'Chain', CycleKind.distance, 4000, 4000, 2),
  _CatalogPart('p_front_pad', '前ブレーキパッド', 'Front brake pads', CycleKind.distance, 1500, 1500, 3),
  _CatalogPart('p_rear_pad', '後ブレーキパッド', 'Rear brake pads', CycleKind.distance, 1500, 1500, 4),
  _CatalogPart('p_front_cable', '前ワイヤー', 'Front cable', CycleKind.distance, 5000, 5000, 5),
  _CatalogPart('p_rear_cable', '後ワイヤー', 'Rear cable', CycleKind.distance, 5000, 5000, 6),
  _CatalogPart('p_front_oil', '前ブレーキオイル', 'Front brake fluid', CycleKind.distance, 10000, 10000, 7),
  _CatalogPart('p_rear_oil', '後ブレーキオイル', 'Rear brake fluid', CycleKind.distance, 10000, 10000, 8),
  _CatalogPart('p_front_disc', '前ディスク', 'Front disc', CycleKind.distance, 8000, 8000, 9),
  _CatalogPart('p_rear_disc', '後ディスク', 'Rear disc', CycleKind.distance, 8000, 8000, 10),
  _CatalogPart('p_bar_tape', 'バーテープ', 'Bar tape', CycleKind.distance, 5000, 5000, 11),
  _CatalogPart('p_speed_batt', 'スピードセンサ電池', 'Speed sensor battery', CycleKind.months, 12, 12, 12),
  _CatalogPart('p_power_batt', 'パワーセンサ電池', 'Power meter battery', CycleKind.months, 12, 12, 13),
  _CatalogPart('p_remote_batt', 'リモコン電池', 'Remote battery', CycleKind.months, 12, 12, 14),
  _CatalogPart('p_hr_batt', '心拍計電池', 'Heart rate battery', CycleKind.months, 12, 12, 15),
  _CatalogPart('p_rear_light_batt', 'リヤライト電池', 'Rear light battery', CycleKind.months, 12, 12, 16),
  _CatalogPart('p_pulley', 'プーリー', 'Pulley', CycleKind.distance, 5000, 5000, 17),
];

const _catalogGroups = [
  _CatalogGroup('grp_tire', 'タイヤ', 'Tires', 'p_front_tire', 'p_rear_tire'),
  _CatalogGroup('grp_pad', 'ブレーキパッド', 'Brake pads', 'p_front_pad', 'p_rear_pad'),
  _CatalogGroup('grp_cable', 'ワイヤー', 'Cables', 'p_front_cable', 'p_rear_cable'),
  _CatalogGroup('grp_oil', 'ブレーキオイル', 'Brake fluid', 'p_front_oil', 'p_rear_oil'),
  _CatalogGroup('grp_disc', 'ディスク', 'Discs', 'p_front_disc', 'p_rear_disc'),
];

List<Part> defaultParts({String locale = 'ja'}) {
  return [
    for (final item in _catalogParts)
      _part(
        item.id,
        item.nameFor(locale),
        item.cycle,
        item.recommended,
        item.custom,
        item.order,
      ),
  ];
}

List<DisplayGroup> defaultGroups({String locale = 'ja'}) {
  return [
    for (final item in _catalogGroups)
      DisplayGroup(
        id: item.id,
        gearId: '',
        displayName: item.nameFor(locale),
        frontPartId: item.frontPartId,
        rearPartId: item.rearPartId,
      ),
  ];
}

String inferCatalogLocale(List<Part> parts, {required String fallback}) {
  final jaById = {
    for (final part in defaultParts(locale: 'ja')) part.id: part.registeredName,
  };
  final enById = {
    for (final part in defaultParts(locale: 'en')) part.id: part.registeredName,
  };
  for (final part in parts) {
    final id = catalogIdOf(part.id);
    if (jaById[id] == part.registeredName) {
      return 'ja';
    }
    if (enById[id] == part.registeredName) {
      return 'en';
    }
  }
  return fallback;
}

Part partForGear(Part catalog, String gearId) {
  return catalog.copyWith(
    id: partIdOnGear(catalog.id, gearId),
    gearId: gearId,
  );
}

DisplayGroup groupForGear(DisplayGroup catalog, String gearId) {
  return DisplayGroup(
    id: groupIdOnGear(catalog.id, gearId),
    gearId: gearId,
    displayName: catalog.displayName,
    frontPartId: partIdOnGear(catalog.frontPartId, gearId),
    rearPartId: partIdOnGear(catalog.rearPartId, gearId),
  );
}

Future<void> seedDemoData(
  AppRepository repo, {
  String locale = 'ja',
  String? localeCode,
}) async {
  const aeroad = Gear(id: 'g_aeroad', name: 'Aeroad');
  const endurace = Gear(id: 'g_endurace', name: 'Endurace');
  const grail = Gear(id: 'g_grail', name: 'Grail');
  await repo.upsertGear(aeroad);
  await repo.upsertGear(endurace);
  await repo.upsertGear(grail);

  final origin = parseDate('2023-04-15');
  await seedDefaultCatalogForGear(
    repo,
    aeroad.id,
    startDate: origin,
    locale: locale,
  );
  await seedDefaultCatalogForGear(
    repo,
    endurace.id,
    startDate: origin,
    locale: locale,
  );
  await seedDefaultCatalogForGear(
    repo,
    grail.id,
    startDate: origin,
    locale: locale,
  );

  final puncture = locale == 'en' ? 'Replaced after a puncture' : 'パンク後に交換';
  final sidewall = locale == 'en' ? 'Sidewall cut' : 'サイドカット';
  final replacements = <Replacement>[
    _rep('r_ft1', 'p_front_tire', '2023-04-02', ''),
    _rep('r_ft2', 'p_front_tire', '2024-01-15', puncture),
    _rep('r_ft3', 'p_front_tire', '2025-05-01', 'GP5000'),
    _rep('r_rt1', 'p_rear_tire', '2024-06-20', ''),
    _rep('r_rt2', 'p_rear_tire', '2025-08-01', sidewall),
    _rep('r_ch1', 'p_chain', '2025-11-12', ''),
    _rep('r_fp1', 'p_front_pad', '2026-04-01', ''),
    _rep('r_rp1', 'p_rear_pad', '2026-06-01', ''),
    _rep('r_fc1', 'p_front_cable', '2025-08-01', ''),
    _rep('r_rc1', 'p_rear_cable', '2025-08-01', ''),
    _rep('r_fo1', 'p_front_oil', '2026-01-20', ''),
    _rep('r_ro1', 'p_rear_oil', '2026-01-20', ''),
    _rep('r_fd1', 'p_front_disc', '2025-03-01', ''),
    _rep('r_rd1', 'p_rear_disc', '2025-03-01', ''),
    _rep('r_tape1', 'p_bar_tape', '2026-01-20', ''),
    _rep('r_spb1', 'p_speed_batt', '2026-01-20', ''),
    _rep('r_pwb1', 'p_power_batt', '2026-01-20', ''),
    _rep('r_rmb1', 'p_remote_batt', '2026-01-20', ''),
    _rep('r_hrb1', 'p_hr_batt', '2026-01-20', ''),
    _rep('r_rlb1', 'p_rear_light_batt', '2026-01-20', ''),
    _rep('r_pul1', 'p_pulley', '2025-11-12', ''),
  ];
  final demoPartIds = {for (final replacement in replacements) replacement.partId};
  for (final partId in demoPartIds) {
    await repo.deleteReplacementsForPart(partId);
  }
  for (final replacement in replacements) {
    await repo.upsertReplacement(replacement);
  }

  var rideIndex = 0;
  var month = DateTime.utc(2023, 4, 15);
  final lastRide = DateTime.utc(2026, 7, 15);
  while (!month.isAfter(lastRide)) {
    await repo.upsertRide(
      Ride(
        id: 'ride_$rideIndex',
        gearId: aeroad.id,
        startedOn: month,
        distanceKm: 320,
      ),
    );
    rideIndex += 1;
    month = DateTime.utc(month.year, month.month + 1, 15);
  }

  await repo.saveSettings(
    AppSettings(
      selectedGearId: aeroad.id,
      lastSyncFrom: parseDate('2025-07-17'),
      localeCode: localeCode,
    ),
  );
}

const retiredDefaultPartIds = {'p_battery'};

Future<void> seedDefaultCatalogForGear(
  AppRepository repo,
  String gearId, {
  required DateTime startDate,
  String locale = 'ja',
}) async {
  for (final retired in retiredDefaultPartIds) {
    await repo.deletePart(retired);
    await repo.deletePart(partIdOnGear(retired, gearId));
  }
  final existingParts = await repo.loadParts(gearId: gearId);
  final catalogLocale = inferCatalogLocale(existingParts, fallback: locale);
  for (final catalog in defaultParts(locale: catalogLocale)) {
    final existing = existingParts.where((part) {
      return matchesCatalogPart(part.id, catalog.id, gearId);
    }).toList();
    if (existing.isNotEmpty) {
      final part = existing.first;
      if (part.cycle != catalog.cycle ||
          part.recommendedLimit != catalog.recommendedLimit) {
        await repo.upsertPart(
          part.copyWith(
            cycle: catalog.cycle,
            recommendedLimit: catalog.recommendedLimit,
            customLimit: catalog.customLimit,
          ),
        );
      }
      continue;
    }
    final id = partIdOnGear(catalog.id, gearId);
    final created = partForGear(catalog, gearId);
    await repo.upsertPart(created.copyWith(id: id));
    await repo.upsertReplacement(
      Replacement(
        id: 'r_${id}_init',
        partId: id,
        gearId: gearId,
        replacedOn: dateOnly(startDate),
        memo: '',
      ),
    );
  }

  final parts = await repo.loadParts(gearId: gearId);
  final partIds = {for (final part in parts) part.id};
  final existingGroups = await repo.loadGroups(gearId: gearId);
  final groupedPartIds = <String>{};
  for (final group in existingGroups) {
    groupedPartIds.add(group.frontPartId);
    groupedPartIds.add(group.rearPartId);
  }
  for (final catalog in defaultGroups(locale: catalogLocale)) {
    final group = groupForGear(catalog, gearId);
    if (existingGroups.any((item) => item.id == group.id)) {
      continue;
    }
    if (!partIds.contains(group.frontPartId) ||
        !partIds.contains(group.rearPartId)) {
      continue;
    }
    if (groupedPartIds.contains(group.frontPartId) ||
        groupedPartIds.contains(group.rearPartId)) {
      continue;
    }
    await repo.insertGroup(group);
    groupedPartIds.add(group.frontPartId);
    groupedPartIds.add(group.rearPartId);
  }
}

/// すでに部品がある端末でも、初期カタログに合わせる。
Future<void> ensureMissingDefaultParts(
  AppRepository repo, {
  required DateTime now,
  DateTime? startDate,
  String? gearId,
  String locale = 'ja',
}) async {
  final gears = await repo.loadGears();
  final rides = await repo.loadRides();
  final targets = <String>{
    if (gearId != null && gearId.isNotEmpty) gearId,
    for (final gear in gears) gear.id,
  };
  for (final id in targets) {
    await seedDefaultCatalogForGear(
      repo,
      id,
      startDate: oldestRideOn(rides: rides, gearId: id) ?? startDate ?? now,
      locale: locale,
    );
  }
}

Future<void> migrateToPerGearParts(Database db) async {
  await db.execute(
    "ALTER TABLE parts ADD COLUMN gear_id TEXT NOT NULL DEFAULT ''",
  );
  await db.execute(
    "ALTER TABLE display_groups ADD COLUMN gear_id TEXT NOT NULL DEFAULT ''",
  );

  final selected = await db.query(
    'settings',
    where: 'key = ?',
    whereArgs: ['selected_gear_id'],
  );
  var sourceGearId = selected.isEmpty ? '' : '${selected.first['value'] ?? ''}';
  final gears = await db.query('gears');
  if (sourceGearId.isEmpty && gears.isNotEmpty) {
    sourceGearId = '${gears.first['id']}';
  }
  if (sourceGearId.isEmpty) {
    return;
  }

  await db.update(
    'parts',
    {'gear_id': sourceGearId},
    where: "gear_id = ''",
  );
  await db.update(
    'display_groups',
    {'gear_id': sourceGearId},
    where: "gear_id = ''",
  );

  final repo = AppRepository(db);
  final rides = await repo.loadRides();
  for (final row in gears) {
    final id = '${row['id']}';
    if (id == sourceGearId) {
      continue;
    }
    await seedDefaultCatalogForGear(
      repo,
      id,
      startDate: oldestRideOn(rides: rides, gearId: id) ?? DateTime.now(),
      locale: 'ja',
    );
  }
}

Part _part(
  String id,
  String name,
  CycleKind cycle,
  int recommended,
  int custom,
  int order,
) {
  return Part(
    id: id,
    gearId: '',
    registeredName: name,
    cycle: cycle,
    limitMode: LimitMode.recommended,
    recommendedLimit: recommended,
    customLimit: custom,
    thresholdPct: 80,
    sortOrder: order,
  );
}

Replacement _rep(String id, String partId, String date, String memo) {
  const gearId = 'g_aeroad';
  return Replacement(
    id: id,
    partId: partIdOnGear(partId, gearId),
    gearId: gearId,
    replacedOn: parseDate(date),
    memo: memo,
  );
}
