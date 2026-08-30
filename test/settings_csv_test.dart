import 'package:flutter_test/flutter_test.dart';
import 'package:gear_doctor/data/seed.dart';
import 'package:gear_doctor/domain/settings_csv.dart';
import 'package:gear_doctor/models/models.dart';

void main() {
  const chain = Part(
    id: 'p_chain',
    gearId: 'g',
    registeredName: 'チェーン',
    cycle: CycleKind.distance,
    limitMode: LimitMode.recommended,
    recommendedLimit: 4000,
    customLimit: 4000,
    thresholdPct: 80,
    sortOrder: 2,
  );
  const front = Part(
    id: 'p_front_tire',
    gearId: 'g',
    registeredName: '前タイヤ',
    cycle: CycleKind.distance,
    limitMode: LimitMode.recommended,
    recommendedLimit: 6000,
    customLimit: 5000,
    thresholdPct: 80,
    sortOrder: 0,
  );
  const rear = Part(
    id: 'p_rear_tire',
    gearId: 'g',
    registeredName: '後タイヤ',
    cycle: CycleKind.distance,
    limitMode: LimitMode.recommended,
    recommendedLimit: 6000,
    customLimit: 5000,
    thresholdPct: 80,
    sortOrder: 1,
  );
  const group = DisplayGroup(
    id: 'grp_tire',
    gearId: 'g',
    displayName: 'タイヤ',
    frontPartId: 'p_front_tire',
    rearPartId: 'p_rear_tire',
  );

  test('export includes cycle, limits, threshold, and F/R group', () {
    final csv = exportSettingsCsv(parts: const [front, rear, chain], groups: const [group]);
    expect(
      csv,
      '$settingsCsvHeader\n'
      '前タイヤ,距離,推奨,6000,5000,80,タイヤ,F\n'
      '後タイヤ,距離,推奨,6000,5000,80,タイヤ,R\n'
      'チェーン,距離,推奨,4000,4000,80,,\n',
    );
  });

  test('round-trip export and reject incomplete groups', () {
    final csv = exportSettingsCsv(parts: const [front, rear, chain], groups: const [group]);
    final parsed = parseSettingsCsv(csv);
    expect(parsed.errors, isEmpty);
    final plan = planSettingsImport(
      rows: parsed.rows,
      parts: const [front, rear, chain],
    );
    expect(plan.canImport, isTrue);
    expect(plan.groups.single.displayName, 'タイヤ');

    final bad = parseSettingsCsv('''
$settingsCsvHeader
前タイヤ,距離,推奨,6000,5000,80,タイヤ,F
''');
    expect(bad.errors, isEmpty);
    final badPlan = planSettingsImport(rows: bad.rows, parts: const [front]);
    expect(badPlan.errors.single, contains('F と R'));
  });

  test('example of default catalog parses', () {
    final csv = exportSettingsCsv(
      parts: defaultParts().map((part) => partForGear(part, 'ex')).toList(),
      groups: defaultGroups().map((group) => groupForGear(group, 'ex')).toList(),
    );
    final parsed = parseSettingsCsv(csv);
    expect(parsed.errors, isEmpty);
    expect(parsed.rows, hasLength(18));
    final plan = planSettingsImport(rows: parsed.rows, parts: const []);
    expect(plan.canImport, isTrue);
    expect(plan.toApply, hasLength(18));
    expect(plan.groups, hasLength(5));
  });
}
