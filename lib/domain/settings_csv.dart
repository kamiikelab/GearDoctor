import '../models/models.dart';
import 'replacement_csv.dart';

const settingsCsvHeader = '登録名,周期,目安,推奨の値,設定の値,しきい値,まとめ,位置';
const settingsCsvHeaderEn =
    'Registered name,Interval,Target,Default,Custom,Threshold,Group,Position';

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

SettingsCsvParseResult parseSettingsCsv(String raw) {
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
          '1行目は $settingsCsvHeader または $settingsCsvHeaderEn にしてください。',
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
      errors.add('$lineNumber 行目: 登録名、周期、目安、推奨の値、設定の値、しきい値が必要です。');
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
      errors.add('$lineNumber 行目: 登録名が空です。');
      continue;
    }
    if (cycle == null) {
      errors.add('$lineNumber 行目: 周期は 距離 か 月 にしてください。');
      continue;
    }
    if (mode == null) {
      errors.add('$lineNumber 行目: 目安は 推奨、自動、設定 のどれかにしてください。');
      continue;
    }
    if (recommended == null || recommended <= 0) {
      errors.add('$lineNumber 行目: 推奨の値は 1 以上の整数にしてください。');
      continue;
    }
    if (custom == null || custom <= 0) {
      errors.add('$lineNumber 行目: 設定の値は 1 以上の整数にしてください。');
      continue;
    }
    if (threshold == null || threshold < 1 || threshold > 100) {
      errors.add('$lineNumber 行目: しきい値は 1 から 100 の整数です。');
      continue;
    }
    final side = _parseSide(sideRaw);
    if (sideRaw.isNotEmpty && side == null) {
      errors.add('$lineNumber 行目: 位置は F か R にしてください。');
      continue;
    }
    if (groupName.isEmpty && side != null) {
      errors.add('$lineNumber 行目: 位置があるときはまとめの名前も入れてください。');
      continue;
    }
    if (groupName.isNotEmpty && side == null) {
      errors.add('$lineNumber 行目: まとめがあるときは位置を F か R にしてください。');
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
    errors.add('CSV が空です。');
  } else if (rows.isEmpty && errors.isEmpty) {
    errors.add('データ行がありません。');
  }
  return SettingsCsvParseResult(rows: rows, errors: errors);
}

SettingsImportPlan planSettingsImport({
  required List<SettingsCsvRow> rows,
  required List<Part> parts,
}) {
  final errors = <String>[];
  final byName = <String, List<Part>>{};
  for (final part in parts) {
    byName.putIfAbsent(part.registeredName, () => []).add(part);
  }
  final seen = <String>{};
  final toApply = <SettingsCsvRow>[];
  for (final row in rows) {
    if (seen.contains(row.registeredName)) {
      errors.add('${row.lineNumber} 行目: 登録名「${row.registeredName}」が CSV 内で重複しています。');
      continue;
    }
    seen.add(row.registeredName);
    final matches = byName[row.registeredName] ?? const <Part>[];
    if (matches.length > 1) {
      errors.add('${row.lineNumber} 行目: 登録名「${row.registeredName}」が複数あります。');
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
      errors.add('まとめ「$name」は F と R が1件ずつ必要です。');
      return;
    }
    if (usedNames.contains(fronts.single.registeredName) ||
        usedNames.contains(rears.single.registeredName)) {
      errors.add('まとめ「$name」の部品は、ほかのまとめと重なっています。');
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
}) {
  final ordered = [...parts]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final buffer = StringBuffer('$header\n');
  for (final part in ordered) {
    final group = groupForExport(groups, part.id);
    buffer.write(csvEscape(part.registeredName));
    buffer.write(',');
    buffer.write(_cycleLabel(part.cycle));
    buffer.write(',');
    buffer.write(part.limitMode.label);
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
  return japanese || english;
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
      return LimitMode.custom;
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

String _cycleLabel(CycleKind cycle) =>
    cycle == CycleKind.months ? '月' : '距離';

String _sideLabel(DisplayGroup? group, String partId) {
  if (group == null) {
    return '';
  }
  return group.frontPartId == partId ? 'F' : 'R';
}
