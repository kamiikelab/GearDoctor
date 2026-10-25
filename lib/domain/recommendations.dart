import '../models/models.dart';

String _fold(String value) {
  const marks = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'œ': 'oe',
    'æ': 'ae',
  };
  final buffer = StringBuffer();
  for (final char in value.toLowerCase().split('')) {
    buffer.write(marks[char] ?? char);
  }
  return buffer.toString();
}

int recommendedLimitFor(String registeredName, CycleKind cycle) {
  final name = _fold(registeredName);
  if (cycle == CycleKind.months) {
    if (registeredName.contains('電池') ||
        name.contains('battery') ||
        name.contains('batterie') ||
        name.contains('pile')) {
      return 12;
    }
    return 24;
  }
  if (registeredName.contains('パッド') ||
      name.contains('pad') ||
      name.contains('plaquette')) {
    return 1500;
  }
  if (registeredName.contains('オイル') ||
      name.contains('oil') ||
      name.contains('fluid') ||
      name.contains('liquide') ||
      name.contains('huile')) {
    return 10000;
  }
  if (registeredName.contains('ワイヤー') ||
      registeredName.contains('ケーブル') ||
      name.contains('cable') ||
      name.contains('wire')) {
    return 5000;
  }
  if (registeredName.contains('チェーン') || name.contains('chain')) {
    return 4000;
  }
  if (registeredName.contains('タイヤ') ||
      name.contains('tire') ||
      name.contains('pneu')) {
    return 6000;
  }
  if (registeredName.contains('ディスク') ||
      name.contains('disc') ||
      name.contains('disque')) {
    return 8000;
  }
  if (registeredName.contains('バーテープ') ||
      registeredName.contains('プーリー') ||
      name.contains('tape') ||
      name.contains('pulley') ||
      name.contains('guidoline') ||
      name.contains('galet')) {
    return 5000;
  }
  return 6000;
}
