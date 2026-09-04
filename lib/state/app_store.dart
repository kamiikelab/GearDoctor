import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/app_database.dart';
import '../data/app_repository.dart';
import '../data/seed.dart';
import '../data/strava_secret_vault.dart';
import '../domain/dates.dart';
import '../domain/replacement_csv.dart';
import '../domain/settings_csv.dart';
import '../domain/usage.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../strava/strava_api.dart';
import '../strava/strava_config.dart';
import '../strava/strava_oauth.dart';

class AppStore extends ChangeNotifier {
  AppStore({
    AppDatabase? database,
    DateTime? now,
    this.deviceLocale = 'ja',
    StravaSecretVault? secretVault,
  })  : _database = database ?? AppDatabase(),
        _nowOverride = now,
        _secretVault = secretVault ?? platformStravaSecretVault();

  final AppDatabase _database;
  final DateTime? _nowOverride;
  final String deviceLocale;
  final StravaSecretVault? _secretVault;

  AppRepository? _repo;
  bool loading = true;
  String? error;

  List<Part> parts = [];
  List<Replacement> replacements = [];
  List<DisplayGroup> groups = [];
  List<Gear> gears = [];
  List<Ride> rides = [];
  AppSettings settings = const AppSettings();

  DateTime get now => dateOnly(_nowOverride ?? DateTime.now());

  String get catalogLocale {
    final code = settings.localeCode;
    if (code == 'en' || code == 'ja') {
      return code!;
    }
    return deviceLocale == 'en' ? 'en' : 'ja';
  }

  bool get usingDemoRides => rides.any((ride) => isDemoRideId(ride.id));

  bool get isManualRideMode => settings.rideSource == RideSource.manual;

  bool get isStravaRideMode => settings.rideSource == RideSource.strava;

  List<Ride> get selectedGearRides {
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      return const [];
    }
    final selected = rides
        .where((ride) => ride.gearId == gearId && !isDemoRideId(ride.id))
        .toList();
    selected.sort((a, b) => b.startedOn.compareTo(a.startedOn));
    return selected;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final db = await _database.instance;
      _repo = AppRepository(db, secretVault: _secretVault);
      if (!await _repo!.hasInitialized()) {
        await seedDemoData(_repo!, locale: catalogLocale);
      } else {
        final existingSettings = await _repo!.loadSettings();
        settings = existingSettings;
        await ensureMissingDefaultParts(
          _repo!,
          now: now,
          startDate: oldestRideOn(
                rides: await _repo!.loadRides(),
                gearId: existingSettings.selectedGearId,
              ) ??
              now,
          gearId: existingSettings.selectedGearId,
          locale: catalogLocale,
        );
      }
      await refresh();
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final repo = _requireRepo();
    gears = await repo.loadGears();
    rides = await repo.loadRides();
    settings = await repo.loadSettings();
    final gearId = settings.selectedGearId;
    parts = gearId == null ? [] : await repo.loadParts(gearId: gearId);
    groups = gearId == null ? [] : await repo.loadGroups(gearId: gearId);
    replacements = await repo.loadReplacements();
    await _backfillRideSourceIfNeeded();
    loading = false;
    notifyListeners();
  }

  Future<void> _backfillRideSourceIfNeeded() async {
    if (settings.rideSource != null || usingDemoRides) {
      return;
    }
    final hasManual = rides.any((ride) => isManualRideId(ride.id));
    final hasStrava = rides.any((ride) => isStravaRideId(ride.id));
    if (!hasManual && !hasStrava) {
      return;
    }
    final repo = _requireRepo();
    if (hasManual) {
      if (hasStrava) {
        await repo.deleteRidesWhere((ride) => isStravaRideId(ride.id));
        rides = await repo.loadRides();
      }
      settings = settings.copyWith(rideSource: RideSource.manual);
    } else {
      settings = settings.copyWith(rideSource: RideSource.strava);
    }
    await repo.saveSettings(settings);
  }

  DateTime? get newestSyncedOn => newestRideOn(
        rides: rides,
        fromInclusive: settings.lastSyncFrom,
      );

  DateTime? get newestSelectedRideOn {
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      return null;
    }
    DateTime? newest;
    for (final ride in rides) {
      if (ride.gearId != gearId) {
        continue;
      }
      final day = dateOnly(ride.startedOn);
      if (newest == null || day.isAfter(newest)) {
        newest = day;
      }
    }
    return newest;
  }

  DateTime? get oldestSelectedRideOn => oldestRideOn(
        rides: rides,
        gearId: settings.selectedGearId,
      );

  DateTime get partOriginOn => oldestSelectedRideOn ?? now;

  Gear? get selectedGear {
    final id = settings.selectedGearId;
    if (id == null) {
      return null;
    }
    for (final gear in gears) {
      if (gear.id == id) {
        return gear;
      }
    }
    return null;
  }

  bool get canManageRecords => selectedGear != null;

  List<Replacement> replacementsFor(String partId) {
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      return [];
    }
    return replacements
        .where((item) => item.partId == partId && item.gearId == gearId)
        .toList();
  }

  double usedOf(Part part) {
    return currentUsed(
      part: part,
      replacements: replacementsFor(part.id),
      rides: rides,
      gearId: settings.selectedGearId,
      now: now,
    );
  }

  int? previousCycleOf(Part part) {
    return previousCycleUsed(
      part: part,
      replacements: replacementsFor(part.id),
      rides: rides,
      gearId: settings.selectedGearId,
      trackingFrom: oldestSelectedRideOn,
    );
  }

  int limitOf(Part part) {
    return resolveLimit(part, previousCycle: previousCycleOf(part));
  }

  String limitModeLabelOf(Part part, AppLocalizations l10n) {
    if (part.limitMode == LimitMode.previousCycle &&
        previousCycleOf(part) == null) {
      return l10n.limitModeAutoFallback;
    }
    return switch (part.limitMode) {
      LimitMode.recommended => l10n.limitModeRecommended,
      LimitMode.previousCycle => l10n.limitModeAuto,
      LimitMode.custom => l10n.limitModeCustom,
    };
  }

  List<HistoryRow> historyOf(Part part) {
    return historyRows(
      replacements: replacementsFor(part.id),
      rides: rides,
      gearId: settings.selectedGearId,
      trackingFrom: oldestSelectedRideOn,
    );
  }

  double gearKmThrough(DateTime throughInclusive) {
    return rideKmThrough(
      rides: rides,
      gearId: settings.selectedGearId,
      fromInclusive: oldestSelectedRideOn,
      throughInclusive: throughInclusive,
    );
  }

  List<DisplayCard> get cards =>
      buildDisplayCards(parts: parts, groups: groups);

  List<AlertItem> get alerts {
    final used = {for (final part in parts) part.id: usedOf(part)};
    final limits = {for (final part in parts) part.id: limitOf(part)};
    return collectAlerts(
      parts: parts,
      groups: groups,
      usedByPartId: used,
      limitByPartId: limits,
    );
  }

  Part? partById(String id) {
    for (final part in parts) {
      if (part.id == id) {
        return part;
      }
    }
    return null;
  }

  DisplayGroup? groupOf(String partId) => groupForPart(groups, partId);

  String titleOf(Part part) => displayTitle(part: part, groups: groups);

  Future<void> savePart(Part part, {required bool isNew}) async {
    if (isNew) {
      _ensureNotDemoForPartsAndCsv();
    }
    final gearId = part.gearId.isNotEmpty
        ? part.gearId
        : settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから部品を追加してください。');
    }
    final repo = _requireRepo();
    await repo.upsertPart(part.copyWith(gearId: gearId));
    if (isNew) {
      await repo.upsertReplacement(
        Replacement(
          id: newId('r'),
          partId: part.id,
          gearId: gearId,
          replacedOn: partOriginOn,
          memo: '',
        ),
      );
    }
    await refresh();
  }

  Future<void> deletePart(String partId) async {
    _ensureNotDemoForPartsAndCsv();
    final part = partById(partId);
    if (part == null) {
      return;
    }
    final repo = _requireRepo();
    if (isCatalogPartId(part.id)) {
      await repo.addRemovedCatalogPart(
        gearId: part.gearId,
        catalogId: catalogIdOf(part.id),
      );
    }
    await repo.deletePart(part.id);
    await refresh();
  }

  Future<void> addReplacement({
    required String partId,
    required DateTime replacedOn,
    required String memo,
  }) async {
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから交換を記録してください。');
    }
    await _requireRepo().upsertReplacement(
      Replacement(
        id: newId('r'),
        partId: partId,
        gearId: gearId,
        replacedOn: dateOnly(replacedOn),
        memo: memo.trim(),
      ),
    );
    await refresh();
  }

  Future<void> updateReplacement(Replacement replacement) async {
    await _requireRepo().upsertReplacement(
      Replacement(
        id: replacement.id,
        partId: replacement.partId,
        gearId: replacement.gearId,
        replacedOn: dateOnly(replacement.replacedOn),
        memo: replacement.memo.trim(),
      ),
    );
    await refresh();
  }

  Future<void> deleteReplacement(String id) async {
    await _requireRepo().deleteReplacement(id);
    await refresh();
  }

  Future<ReplacementImportResult> importReplacementPlan(
    ReplacementImportPlan plan,
  ) async {
    if (!plan.canImport) {
      return ReplacementImportResult(
        added: 0,
        skippedDuplicates: plan.duplicates.length,
      );
    }
    _ensureNotDemoForPartsAndCsv();
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから CSV を取り込んでください。');
    }
    final repo = _requireRepo();
    final partIds = <String>{};
    for (final row in plan.toAdd) {
      final part = partForCsvRow(row, parts);
      if (part != null) {
        partIds.add(part.id);
      }
    }
    for (final partId in partIds) {
      await repo.deleteReplacementsForPartGear(partId, gearId);
    }
    for (final row in plan.toAdd) {
      final part = partForCsvRow(row, parts);
      if (part == null) {
        continue;
      }
      await repo.upsertReplacement(
        Replacement(
          id: newId('r'),
          partId: part.id,
          gearId: gearId,
          replacedOn: dateOnly(row.replacedOn),
          memo: row.memo,
        ),
      );
    }
    await refresh();
    return ReplacementImportResult(
      added: plan.toAdd.length,
      skippedDuplicates: plan.duplicates.length,
    );
  }

  Future<SettingsImportResult> importSettingsPlan(SettingsImportPlan plan) async {
    if (!plan.canImport) {
      return const SettingsImportResult(updated: 0, created: 0, grouped: 0);
    }
    _ensureNotDemoForPartsAndCsv();
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから CSV を取り込んでください。');
    }
    final repo = _requireRepo();
    final byName = <String, Part>{};
    for (final part in parts) {
      byName[part.registeredName] = part;
    }
    var sort = nextSortOrder();
    var updated = 0;
    var created = 0;
    final applied = <String, Part>{};
    for (final row in plan.toApply) {
      final existing = byName[row.registeredName];
      if (existing == null) {
        final createdPart = Part(
          id: newId('p'),
          gearId: gearId,
          registeredName: row.registeredName,
          cycle: row.cycle,
          limitMode: row.limitMode,
          recommendedLimit: row.recommendedLimit,
          customLimit: row.customLimit,
          thresholdPct: row.thresholdPct,
          sortOrder: sort,
        );
        sort += 1;
        await repo.upsertPart(createdPart);
        await repo.upsertReplacement(
          Replacement(
            id: newId('r'),
            partId: createdPart.id,
            gearId: gearId,
            replacedOn: partOriginOn,
            memo: '',
          ),
        );
        created += 1;
        applied[row.registeredName] = createdPart;
      } else {
        final updatedPart = existing.copyWith(
          cycle: row.cycle,
          limitMode: row.limitMode,
          recommendedLimit: row.recommendedLimit,
          customLimit: row.customLimit,
          thresholdPct: row.thresholdPct,
        );
        await repo.upsertPart(updatedPart);
        updated += 1;
        applied[row.registeredName] = updatedPart;
      }
    }
    final touched = {for (final part in applied.values) part.id};
    for (final group in groups) {
      if (touched.contains(group.frontPartId) || touched.contains(group.rearPartId)) {
        await repo.deleteGroup(group.id);
      }
    }
    for (final spec in plan.groups) {
      final front = applied[spec.frontName];
      final rear = applied[spec.rearName];
      if (front == null || rear == null) {
        continue;
      }
      await repo.insertGroup(
        DisplayGroup(
          id: newId('grp'),
          gearId: gearId,
          displayName: spec.displayName,
          frontPartId: front.id,
          rearPartId: rear.id,
        ),
      );
    }
    await refresh();
    return SettingsImportResult(
      updated: updated,
      created: created,
      grouped: plan.groups.length,
    );
  }

  Future<void> combineDisplay({
    required String frontPartId,
    required String rearPartId,
    required String displayName,
  }) async {
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから表示をまとめてください。');
    }
    await _requireRepo().insertGroup(
      DisplayGroup(
        id: newId('grp'),
        gearId: gearId,
        displayName: displayName.trim(),
        frontPartId: frontPartId,
        rearPartId: rearPartId,
      ),
    );
    await refresh();
  }

  Future<void> dissolveGroup(String id) async {
    await _requireRepo().deleteGroup(id);
    await refresh();
  }

  Future<void> selectGear(String gearId) async {
    settings = settings.copyWith(selectedGearId: gearId);
    await _requireRepo().saveSettings(settings);
    await refresh();
  }

  Future<void> addGear(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw StateError('名前を入力してください');
    }
    final repo = _requireRepo();
    final id = newId('g');
    await repo.upsertGear(Gear(id: id, name: trimmed));
    await seedDefaultCatalogForGear(
      repo,
      id,
      startDate: now,
      locale: catalogLocale,
    );
    settings = settings.copyWith(selectedGearId: id);
    await repo.saveSettings(settings);
    await refresh();
  }

  Future<void> addManualRide({
    required DateTime on,
    required double distanceKm,
  }) async {
    _ensureCanEditManualRides();
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから走行を記録してください');
    }
    if (distanceKm <= 0 || distanceKm.isNaN) {
      throw StateError('距離は 0 より大きい数にしてください');
    }
    final repo = _requireRepo();
    if (usingDemoRides) {
      await repo.deleteAllRides();
      settings = settings.copyWith(clearSync: true);
    }
    settings = settings.copyWith(rideSource: RideSource.manual);
    await repo.saveSettings(settings);
    await repo.upsertRide(
      Ride(
        id: newId('manual'),
        gearId: gearId,
        startedOn: dateOnly(on),
        distanceKm: distanceKm,
      ),
    );
    await refresh();
  }

  Future<void> updateManualRide({
    required String id,
    required DateTime on,
    required double distanceKm,
  }) async {
    _ensureCanEditManualRides();
    if (!isManualRideId(id)) {
      throw StateError('Strava の走行は直せません');
    }
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから走行を記録してください');
    }
    if (distanceKm <= 0 || distanceKm.isNaN) {
      throw StateError('距離は 0 より大きい数にしてください');
    }
    final current = rides.where((ride) => ride.id == id);
    if (current.isEmpty || current.first.gearId != gearId) {
      throw StateError('このギアの走行ではありません');
    }
    await _requireRepo().upsertRide(
      Ride(
        id: id,
        gearId: gearId,
        startedOn: dateOnly(on),
        distanceKm: distanceKm,
      ),
    );
    await refresh();
  }

  Future<void> deleteManualRide(String id) async {
    _ensureCanEditManualRides();
    if (!isManualRideId(id)) {
      throw StateError('Strava の走行は消せません');
    }
    final gearId = settings.selectedGearId;
    if (gearId == null) {
      throw StateError('ギアを選んでから走行を記録してください');
    }
    final current = rides.where((ride) => ride.id == id);
    if (current.isEmpty || current.first.gearId != gearId) {
      throw StateError('このギアの走行ではありません');
    }
    await _requireRepo().deleteRidesWhere((ride) => ride.id == id);
    await refresh();
  }

  Future<void> switchToManualRides() async {
    if (usingDemoRides) {
      throw StateError('デモのあいだは切り替えできません');
    }
    final repo = _requireRepo();
    await repo.deleteRidesWhere((ride) => isStravaRideId(ride.id));
    settings = settings.copyWith(
      rideSource: RideSource.manual,
      clearSync: true,
    );
    await repo.saveSettings(settings);
    await refresh();
  }

  void _ensureCanEditManualRides() {
    if (isStravaRideMode) {
      throw StateError('Strava の走行があるときは手入力できません');
    }
  }

  Future<void> deleteGear(String gearId) async {
    if (!isUserDeletableGear(gearId)) {
      throw StateError('Strava から取った自転車は、ここでは消せません。');
    }
    final repo = _requireRepo();
    await repo.deleteGear(gearId);
    final remaining = await repo.loadGears();
    if (remaining.isEmpty) {
      settings = settings.copyWith(clearGear: true);
    } else if (settings.selectedGearId == gearId) {
      settings = settings.copyWith(selectedGearId: remaining.first.id);
    }
    await repo.saveSettings(settings);
    await refresh();
  }

  Future<void> setLocaleCode(String? code) async {
    settings = code == null || code.isEmpty
        ? settings.copyWith(clearLocale: true)
        : settings.copyWith(localeCode: code);
    notifyListeners();
    await _requireRepo().saveSettings(settings);
  }

  Future<void> saveStravaCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    settings = settings.copyWith(
      stravaClientId: clientId.trim(),
      stravaClientSecret: clientSecret.trim(),
    );
    await _requireRepo().saveSettings(settings);
    notifyListeners();
  }

  Future<void> saveStravaAuth(StravaAuthResult result) async {
    settings = settings.copyWith(
      stravaAccessToken: result.accessToken,
      stravaRefreshToken: result.refreshToken,
      stravaExpiresAt: result.expiresAt,
      stravaAthleteId: result.athleteId,
      stravaAthleteName: result.athleteName,
    );
    await _requireRepo().saveSettings(settings);
    await _adoptStravaBikes(result.bikes);
    await refresh();
  }

  Future<void> disconnectStrava({void Function(String token)? remoteRevoke}) async {
    final token = settings.stravaAccessToken;
    if (token != null && remoteRevoke != null) {
      remoteRevoke(token);
    }
    settings = settings.copyWith(clearTokens: true);
    await _requireRepo().saveSettings(settings);
    notifyListeners();
  }

  Future<void> resetToDemo() async {
    final repo = _requireRepo();
    final locale = catalogLocale;
    final localeCode = settings.localeCode;
    await repo.clearAllTables();
    await seedDemoData(repo, locale: locale, localeCode: localeCode);
    await refresh();
  }

  Future<void> changeSyncStart(DateTime from) async {
    final next = dateOnly(from);
    final current = settings.lastSyncFrom == null
        ? null
        : dateOnly(settings.lastSyncFrom!);
    if (current != null && current == next) {
      return;
    }
    final repo = _requireRepo();
    if (settings.rideSource != RideSource.manual) {
      await repo.deleteAllRides();
    }
    settings = settings.copyWith(clearSync: true).copyWith(lastSyncFrom: next);
    await repo.saveSettings(settings);
    await refresh();
  }

  Future<StravaSyncSummary> syncForward({
    required int months,
    http.Client? client,
  }) async {
    final start = settings.lastSyncFrom;
    if (start == null) {
      throw StravaAuthException('先に開始日を指定してください。');
    }
    if (!settings.stravaConnected) {
      throw StravaAuthException('先に Strava 連携の画面から連携してください。');
    }
    final owned = client == null;
    final httpClient = client ?? http.Client();
    try {
      var tokens = await _ensureTokens(httpClient);
      Future<T> run<T>(Future<T> Function(String token) action) async {
        try {
          return await action(tokens.accessToken);
        } on StravaAuthException catch (error) {
          if (!error.message.contains('認可が無効')) {
            rethrow;
          }
          tokens = await _ensureTokens(httpClient, forceRefresh: true);
          return action(tokens.accessToken);
        }
      }

      final bikes = await run(
        (token) => fetchAthleteBikes(client: httpClient, accessToken: token),
      );
      await _adoptStravaBikes(bikes);

      final repo = _requireRepo();
      if (rides.any((ride) => isDemoRideId(ride.id))) {
        await repo.deleteAllRides();
        rides = [];
      }
      if (rides.any((ride) => isManualRideId(ride.id)) ||
          settings.rideSource == RideSource.manual) {
        await repo.deleteRidesWhere((ride) => isManualRideId(ride.id));
        rides = rides.where((ride) => !isManualRideId(ride.id)).toList();
      }

      final window = nextSyncWindow(
        startDate: start,
        fetchedThrough: settings.lastSyncAt,
        months: months,
        today: now,
      );
      final fetched = await run(
        (token) => fetchBikeRides(
          client: httpClient,
          accessToken: token,
          fromInclusive: window.fromInclusive,
          toInclusive: window.toInclusive,
        ),
      );
      for (final ride in fetched) {
        await repo.upsertRide(ride);
      }
      settings = settings.copyWith(
        lastSyncAt: window.toInclusive,
        rideSource: RideSource.strava,
      );
      await repo.saveSettings(settings);
      await refresh();
      return StravaSyncSummary(
        from: window.fromInclusive,
        to: window.toInclusive,
        savedCount: fetched.length,
        newestRideOn: newestSyncedOn,
      );
    } finally {
      if (owned) {
        httpClient.close();
      }
    }
  }

  Future<StravaTokens> _ensureTokens(
    http.Client client, {
    bool forceRefresh = false,
  }) async {
    var clientId = settings.stravaClientId ?? '';
    var clientSecret = settings.stravaClientSecret ?? '';
    if (clientId.isEmpty || clientSecret.isEmpty) {
      final loaded = await resolveStravaCredentials(
        storedClientId: settings.stravaClientId,
        storedClientSecret: settings.stravaClientSecret,
      );
      clientId = loaded?.clientId ?? '';
      clientSecret = loaded?.clientSecret ?? '';
    }
    final tokens = await ensureAccessToken(
      client: client,
      clientId: clientId,
      clientSecret: clientSecret,
      accessToken: settings.stravaAccessToken ?? '',
      refreshToken: settings.stravaRefreshToken ?? '',
      expiresAt: forceRefresh ? DateTime.utc(2000) : settings.stravaExpiresAt,
    );
    settings = settings.copyWith(
      stravaAccessToken: tokens.accessToken,
      stravaRefreshToken: tokens.refreshToken,
      stravaExpiresAt: tokens.expiresAt,
    );
    await _requireRepo().saveSettings(settings);
    return tokens;
  }

  Future<void> _adoptStravaBikes(List<Gear> bikes) async {
    final repo = _requireRepo();
    for (final bike in bikes) {
      await repo.upsertGear(bike);
      await seedDefaultCatalogForGear(
        repo,
        bike.id,
        startDate: oldestRideOn(rides: rides, gearId: bike.id) ?? now,
        locale: catalogLocale,
      );
    }
    if (bikes.isEmpty) {
      return;
    }
    for (final id in demoGearIds) {
      await repo.deleteGear(id);
    }
    final selected = settings.selectedGearId;
    final known = bikes.any((bike) => bike.id == selected);
    if (!known) {
      settings = settings.copyWith(selectedGearId: bikes.first.id);
      await repo.saveSettings(settings);
    }
  }

  int nextSortOrder() {
    var maxOrder = -1;
    for (final part in parts) {
      if (part.sortOrder > maxOrder) {
        maxOrder = part.sortOrder;
      }
    }
    return maxOrder + 1;
  }

  List<Part> get ungroupedParts {
    final grouped = <String>{};
    for (final group in groups) {
      grouped.add(group.frontPartId);
      grouped.add(group.rearPartId);
    }
    return parts.where((part) => !grouped.contains(part.id)).toList();
  }

  String newId(String prefix) {
    final random = Random();
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1 << 32)}';
  }

  AppRepository _requireRepo() {
    final repo = _repo;
    if (repo == null) {
      throw StateError('データベースがまだ開いていません');
    }
    return repo;
  }

  void _ensureNotDemoForPartsAndCsv() {
    if (usingDemoRides) {
      throw const DemoRequiresSyncException();
    }
  }

  @visibleForTesting
  Future<void> convertDemoRidesForTest() async {
    final repo = _requireRepo();
    final current = List<Ride>.from(rides);
    await repo.deleteAllRides();
    for (final ride in current) {
      await repo.upsertRide(
        Ride(
          id: isDemoRideId(ride.id) ? 'synced_${ride.id}' : ride.id,
          gearId: ride.gearId,
          startedOn: ride.startedOn,
          distanceKm: ride.distanceKm,
        ),
      );
    }
    await refresh();
  }
}
