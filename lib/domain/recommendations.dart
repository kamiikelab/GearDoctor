import '../models/models.dart';

int recommendedLimitFor(String registeredName, CycleKind cycle) {
  final name = registeredName.toLowerCase();
  if (cycle == CycleKind.months) {
    if (registeredName.contains('電池') || name.contains('battery')) {
      return 12;
    }
    return 24;
  }
  if (registeredName.contains('パッド') || name.contains('pad')) {
    return 1500;
  }
  if (registeredName.contains('オイル') ||
      name.contains('oil') ||
      name.contains('fluid')) {
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
  if (registeredName.contains('タイヤ') || name.contains('tire')) {
    return 6000;
  }
  if (registeredName.contains('ディスク') || name.contains('disc')) {
    return 8000;
  }
  if (registeredName.contains('バーテープ') ||
      registeredName.contains('プーリー') ||
      name.contains('tape') ||
      name.contains('pulley')) {
    return 5000;
  }
  return 6000;
}
