import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/seed.dart';
import '../domain/settings_csv.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class ImportSettingsScreen extends StatefulWidget {
  const ImportSettingsScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<ImportSettingsScreen> createState() => _ImportSettingsScreenState();
}

class _ImportSettingsScreenState extends State<ImportSettingsScreen> {
  final _csv = TextEditingController();
  SettingsCsvParseResult? _parsed;
  SettingsImportPlan? _plan;
  String? _message;

  bool get _readyToConfirm => _plan != null && _plan!.canImport;

  @override
  void initState() {
    super.initState();
    _csv.addListener(_onCsvChanged);
  }

  @override
  void dispose() {
    _csv.removeListener(_onCsvChanged);
    _csv.dispose();
    super.dispose();
  }

  void _onCsvChanged() {
    if (_parsed == null && _plan == null) {
      return;
    }
    setState(() {
      _parsed = null;
      _plan = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final selected = widget.store.selectedGear;
        final canManage = widget.store.canManageRecords;
        final gearLabel = selected == null
            ? '未選択'
            : demoGearLabel(selected.name, demo: isDemoGearId(selected.id));
        return Scaffold(
          appBar: AppBar(title: const Text('部品の CSV')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                gearLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canManage
                    ? 'このギアの部品設定だけを出し入れします。他のギアはそのままです。'
                    : 'Strava から自転車を取って選ぶと、この画面が使えます。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const Text('入力欄に出してコピーします。'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: canManage ? _export : null,
                child: const Text('いまの設定を書き出す'),
              ),
              const SizedBox(height: 16),
              Text('CSV', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              TextField(
                controller: _csv,
                enabled: canManage,
                minLines: 8,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: settingsCsvHeader,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: canManage
                    ? () async {
                        if (await _blockIfDemo()) {
                          return;
                        }
                        setState(() {
                          _csv.text = exportSettingsCsv(
                            parts: defaultParts()
                                .map((part) => partForGear(part, 'example'))
                                .toList(),
                            groups: defaultGroups()
                                .map((group) => groupForGear(group, 'example'))
                                .toList(),
                          );
                          _parsed = null;
                          _plan = null;
                          _message = null;
                        });
                      }
                    : null,
                child: const Text('例を入れる'),
              ),
              const SizedBox(height: 8),
              const Text(
                '登録名で結びます。無い登録名は部品を足します。CSV に出た部品の設定とまとめを、このギアだけ差し替えます。交換記録は変わりません。',
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: canManage && !_readyToConfirm ? _preview : null,
                child: const Text('CSVを取り込み'),
              ),
              if (_readyToConfirm) ...[
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _import,
                  child: const Text('確定'),
                ),
              ],
              if (_errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('直せること', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final error in _errors) Text(error),
              ],
              if (_plan != null && _errors.isEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '部品 ${_plan!.toApply.length} 件'
                  '${_plan!.groups.isEmpty ? '' : '、まとめ ${_plan!.groups.length} 件'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!),
              ],
            ],
          ),
        );
      },
    );
  }

  List<String> get _errors {
    return [
      ...?_parsed?.errors,
      ...?_plan?.errors,
    ];
  }

  Future<void> _export() async {
    final csv = exportSettingsCsv(
      parts: widget.store.parts,
      groups: widget.store.groups,
    );
    setState(() {
      _csv.text = csv;
      _parsed = null;
      _plan = null;
      _message = widget.store.parts.isEmpty
          ? '部品がありません。見出しだけ書き出しました。'
          : '${widget.store.parts.length} 件を入力欄に出し、コピーしました。';
    });
    await Clipboard.setData(ClipboardData(text: csv));
  }

  Future<bool> _blockIfDemo() async {
    if (!widget.store.usingDemoRides) {
      return false;
    }
    setState(() {
      _parsed = null;
      _plan = null;
      _message = DemoRequiresSyncException.message;
    });
    if (mounted) {
      await showDemoRequiresSyncDialog(context);
    }
    return true;
  }

  void _preview() {
    if (widget.store.usingDemoRides) {
      _blockIfDemo();
      return;
    }
    final parsed = parseSettingsCsv(_csv.text);
    SettingsImportPlan? plan;
    if (parsed.errors.isEmpty) {
      plan = planSettingsImport(
        rows: parsed.rows,
        parts: widget.store.parts,
      );
    }
    setState(() {
      _parsed = parsed;
      _plan = plan;
      _message = null;
    });
  }

  Future<void> _import() async {
    if (await _blockIfDemo()) {
      return;
    }
    final plan = _plan;
    if (plan == null || !plan.canImport) {
      return;
    }
    final result = await widget.store.importSettingsPlan(plan);
    if (!mounted) {
      return;
    }
    setState(() {
      _parsed = null;
      _plan = null;
      _message =
          '更新 ${result.updated} 件、追加 ${result.created} 件'
          '${result.grouped == 0 ? '' : '、まとめ ${result.grouped} 件'}'
          'を、このギアに取り込みました。';
    });
  }
}
