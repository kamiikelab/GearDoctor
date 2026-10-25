import '../l10n/active_locale.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import 'replacement_csv.dart';

const settingsCsvHeader = '登録名,周期,目安,推奨の値,設定の値,しきい値,まとめ,位置';
const settingsCsvHeaderEn =
    'Registered name,Interval,Target,Default,Custom,Threshold,Group,Position';
const settingsCsvHeaderFr =
    'Nom enregistré,Intervalle,Objectif,Défaut,Personnalisé,Seuil,Groupe,Position';

enum SettingsSide { front, rear }

class SettingsCsvRow {
  const SettingsCsvRow({
    required this.lineNumber,
    required this.registeredName,
    required this.cycle,
    required this.limitMode,
    required this.recommendedLimit,
    required this.customLimit,
    required this.thresholdPct,
    required this.groupName,
    required this.side,
  });

  final int lineNumber;
  final String registeredName;
  final CycleKind cycle;
  final LimitMode limitMode;
  final int recommendedLimit;
  final int customLimit;
  final int thresholdPct;
  final String groupName;
  final SettingsSide? side;
}

class SettingsGroupSpec {
  const SettingsGroupSpec({
    required this.displayName,
    required this.frontName,
    required this.rearName,
  });

  final String displayName;
  final String frontName;
  final String rearName;
}

class SettingsCsvParseResult {
  const SettingsCsvParseResult({required this.rows, required this.errors});

  final List<SettingsCsvRow> rows;
  final List<String> errors;
}

class SettingsImportPlan {
  const SettingsImportPlan({
    required this.toApply,
    required this.groups,
    required this.errors,
  });

  final List<SettingsCsvRow> toApply;
  final List<SettingsGroupSpec> groups;
  final List<String> errors;

  bool get canImport => errors.isEmpty && toApply.isNotEmpty;
}

class SettingsImportResult {
  const SettingsImportResult({
    required this.updated,
    required this.created,
    required this.grouped,
  });

  final int updated;
  final int created;
  final int grouped;
}

SettingsCsvParseResult parseSettingsCsv(
  String raw, {
  AppLocalizations? messages,
}) {
  final l10n = messages ?? activeL10n;
  final text = raw.replaceFirst('\uFEFF', '').replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = text.split('\n');
  final errors = <String>[];
  final rows = <SettingsCsvRow>[];
  var sawHeader = false;

  for (var i = 0; i < lines.length; i++) {
    final lineNumber = i + 1;
    final line = lines[i].trim();
    if (line.isEmpty) {
      continue;
    }
    final fields = parseCsvLine(line);
    if (!sawHeader) {
      if (!_isSettingsHeader(fields)) {
        errors.add(
          l10n.csvSettingsHeaderError(
            settingsCsvHeader,
            settingsCsvHeaderEn,
            settingsCsvHeaderFr,
          ),
        );
        return SettingsCsvParseResult(rows: const [], errors: errors);
      }
      sawHeader = true;
      continue;
    }
    if (fields.every((field) => field.trim().isEmpty)) {
      continue;
    }
    if (fields.length < 6) {
      errors.add(l10n.csvSettingsNeedFields(lineNumber));
      continue;
    }
    final name = fields[0].trim();
    final cycle = _parseCycle(fields[1].trim());
    final mode = _parseLimitMode(fields[2].trim());
    final recommended = int.tryParse(fields[3].trim());
    final custom = int.tryParse(fields[4].trim());
    final threshold = int.tryParse(fields[5].trim());
    final groupName = fields.length <= 6 ? '' : fields[6].trim();
    final sideRaw = fields.length <= 7 ? '' : fields[7].trim();
    if (name.isEmpty) {
      errors.add(l10n.csvEmptyName(lineNumber));
      continue;
    }
    if (cycle == null) {
      errors.add(l10n.csvBadCycle(lineNumber));
      continue;
    }
    if (mode == null) {
      errors.add(l10n.csvBadLimitMode(lineNumber));
      continue;
    }
    if (recommended == null || recommended <= 0) {
      errors.add(l10n.csvBadRecommended(lineNumber));
      continue;
    }
    if (custom == null || custom <= 0) {
      errors.add(l10n.csvBadCustom(lineNumber));
      continue;
    }
    if (threshold == null || threshold < 1 || threshold > 100) {
      errors.add(l10n.csvBadThreshold(lineNumber));
      continue;
    }
    final side = _parseSide(sideRaw);
    if (sideRaw.isNotEmpty && side == null) {
      errors.add(l10n.csvBadSide(lineNumber));
      continue;
    }
    if (groupName.isEmpty && side != null) {
      errors.add(l10n.csvSideNeedsGroup(lineNumber));
      continue;
    }
    if (groupName.isNotEmpty && side == null) {
      errors.add(l10n.csvGroupNeedsSide(lineNumber));
      continue;
    }
    rows.add(
      SettingsCsvRow(
        lineNumber: lineNumber,
        registeredName: name,
        cycle: cycle,
        limitMode: mode,
        recommendedLimit: recommended,
        customLimit: custom,
        thresholdPct: threshold,
        groupName: groupName,
        side: side,
      ),
    );
  }

  if (!sawHeader) {
    errors.add(l10n.csvEmpty);
  } else if (rows.isEmpty && errors.isEmpty) {
    errors.add(l10n.csvNoRows);
  }
  return SettingsCsvParseResult(rows: rows, errors: errors);
}

SettingsImportPlan planSettingsImport({
  required List<SettingsCsvRow> rows,
  required List<Part> parts,
  AppLocalizations? messages,
}) {
  final l10n = messages ?? activeL10n;
  final errors = <String>[];
  final byName = <String, List<Part>>{};
  for (final part in parts) {
    byName.putIfAbsent(part.registeredName, () => []).add(part);
  }
  final seen = <String>{};
  final toApply = <SettingsCsvRow>[];
  for (final row in rows) {
    if (seen.contains(row.registeredName)) {
      errors.add(l10n.csvDuplicateInFile(row.lineNumber, row.registeredName));
      continue;
    }
    seen.add(row.registeredName);
    final matches = byName[row.registeredName] ?? const <Part>[];
    if (matches.length > 1) {
      errors.add(l10n.csvNameAmbiguous(row.lineNumber, row.registeredName));
      continue;
    }
    toApply.add(row);
  }

  final grouped = <String, List<SettingsCsvRow>>{};
  for (final row in toApply) {
    if (row.groupName.isEmpty) {
      continue;
    }
    grouped.putIfAbsent(row.groupName, () => []).add(row);
  }
  final groups = <SettingsGroupSpec>[];
  final usedNames = <String>{};
  grouped.forEach((name, members) {
    final fronts = members.where((row) => row.side == SettingsSide.front).toList();
    final rears = members.where((row) => row.side == SettingsSide.rear).toList();
    if (members.length != 2 || fronts.length != 1 || rears.length != 1) {
      errors.add(l10n.csvGroupNeedsBothSides(name));
      return;
    }
    if (usedNames.contains(fronts.single.registeredName) ||
        usedNames.contains(rears.single.registeredName)) {
      errors.add(l10n.csvGroupOverlap(name));
      return;
    }
    usedNames.add(fronts.single.registeredName);
    usedNames.add(rears.single.registeredName);
    groups.add(
      SettingsGroupSpec(
        displayName: name,
        frontName: fronts.single.registeredName,
        rearName: rears.single.registeredName,
      ),
    );
  });

  return SettingsImportPlan(
    toApply: errors.isEmpty ? toApply : const [],
    groups: errors.isEmpty ? groups : const [],
    errors: errors,
  );
}

String exportSettingsCsv({
  required List<Part> parts,
  required List<DisplayGroup> groups,
  String header = settingsCsvHeader,
  String locale = 'ja',
}) {
  final ordered = [...parts]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final buffer = StringBuffer('$header\n');
  for (final part in ordered) {
    final group = groupForExport(groups, part.id);
    buffer.write(csvEscape(part.registeredName));
    buffer.write(',');
    buffer.write(_cycleLabel(part.cycle, locale));
    buffer.write(',');
    buffer.write(_limitModeLabel(part.limitMode, locale));
    buffer.write(',');
    buffer.write(part.recommendedLimit);
    buffer.write(',');
    buffer.write(part.customLimit);
    buffer.write(',');
    buffer.write(part.thresholdPct);
    buffer.write(',');
    buffer.write(csvEscape(group?.displayName ?? ''));
    buffer.write(',');
    buffer.writeln(_sideLabel(group, part.id));
  }
  return buffer.toString();
}

DisplayGroup? groupForExport(List<DisplayGroup> groups, String partId) {
  for (final group in groups) {
    if (group.contains(partId)) {
      return group;
    }
  }
  return null;
}

bool _isSettingsHeader(List<String> fields) {
  if (fields.length < 6) {
    return false;
  }
  final name = fields[0].trim().toLowerCase();
  final cycle = fields[1].trim().toLowerCase();
  final japanese = name == '登録名' && cycle == '周期';
  final english = name == 'registered name' && cycle == 'interval';
  final french = name == 'nom enregistré' && cycle == 'intervalle';
  return japanese || english || french;
}

CycleKind? _parseCycle(String raw) {
  switch (raw.toLowerCase()) {
    case '距離':
    case 'km':
    case 'distance':
      return CycleKind.distance;
    case '月':
    case 'か月':
    case 'months':
    case 'month':
    case 'mois':
      return CycleKind.months;
    default:
      return null;
  }
}

LimitMode? _parseLimitMode(String raw) {
  switch (raw.toLowerCase()) {
    case '推奨':
    case 'default':
    case 'recommended':
      return LimitMode.recommended;
    case '自動':
    case 'auto':
      return LimitMode.previousCycle;
    case '設定':
    case 'custom':
    case 'personnalisé':
    case 'personnalise':
      return LimitMode.custom;
    case 'défaut':
    case 'defaut':
      return LimitMode.recommended;
    default:
      return null;
  }
}

SettingsSide? _parseSide(String raw) {
  switch (raw) {
    case 'F':
      return SettingsSide.front;
    case 'R':
      return SettingsSide.rear;
    default:
      return null;
  }
}

String _cycleLabel(CycleKind cycle, String locale) {
  if (locale == 'en') {
    return cycle == CycleKind.months ? 'Months' : 'Distance';
  }
  if (locale == 'fr') {
    return cycle == CycleKind.months ? 'Mois' : 'Distance';
  }
  return cycle == CycleKind.months ? '月' : '距離';
}

String _limitModeLabel(LimitMode mode, String locale) {
  if (locale == 'en') {
    return switch (mode) {
      LimitMode.recommended => 'Default',
      LimitMode.previousCycle => 'Auto',
      LimitMode.custom => 'Custom',
    };
  }
  if (locale == 'fr') {
    return switch (mode) {
      LimitMode.recommended => 'Défaut',
      LimitMode.previousCycle => 'Auto',
      LimitMode.custom => 'Personnalisé',
    };
  }
  return mode.label;
}

String _sideLabel(DisplayGroup? group, String partId) {
  if (group == null) {
    return '';
  }
  return group.frontPartId == partId ? 'F' : 'R';
}
