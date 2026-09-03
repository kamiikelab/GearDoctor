import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/seed.dart';
import '../domain/settings_csv.dart';
import '../l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context);
        final selected = widget.store.selectedGear;
        final canManage = widget.store.canManageRecords;
        final gearLabel = selected == null
            ? l10n.gearUnselected
            : demoGearLabel(
                selected.name,
                l10n,
                demo: isDemoGearId(selected.id),
              );
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsCsv)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                gearLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canManage ? l10n.settingsCsvScope : l10n.csvNeedGear,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(l10n.csvCopyHint),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: canManage ? _export : null,
                child: Text(l10n.exportCurrentSettings),
              ),
              const SizedBox(height: 16),
              Text(l10n.csvLabel, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              AppTextField(
                controller: _csv,
                enabled: canManage,
                minLines: 8,
                maxLines: 8,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.settingsCsvHint,
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
                            parts: defaultParts(
                              locale: widget.store.catalogLocale,
                            )
                                .map((part) => partForGear(part, 'example'))
                                .toList(),
                            groups: defaultGroups(
                              locale: widget.store.catalogLocale,
                            )
                                .map((group) => groupForGear(group, 'example'))
                                .toList(),
                            header: l10n.settingsCsvHint,
                          );
                          _parsed = null;
                          _plan = null;
                          _message = null;
                        });
                      }
                    : null,
                child: Text(l10n.insertExample),
              ),
              const SizedBox(height: 8),
              Text(l10n.settingsCsvHelp),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: canManage && !_readyToConfirm ? _preview : null,
                child: Text(l10n.importCsv),
              ),
              if (_readyToConfirm) ...[
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _import,
                  child: Text(l10n.confirm),
                ),
              ],
              if (_errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.fixThese, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final error in _errors) Text(error),
              ],
              if (_plan != null && _errors.isEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${l10n.partsApplyCount(_plan!.toApply.length)}'
                  '${_plan!.groups.isEmpty ? '' : l10n.groupsCountPreview(_plan!.groups.length)}',
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
    final l10n = AppLocalizations.of(context);
    final csv = exportSettingsCsv(
      parts: widget.store.parts,
      groups: widget.store.groups,
      header: l10n.settingsCsvHint,
    );
    setState(() {
      _csv.text = csv;
      _parsed = null;
      _plan = null;
      _message = widget.store.parts.isEmpty
          ? l10n.exportedEmptySettings
          : l10n.exportedCount(widget.store.parts.length);
    });
    await Clipboard.setData(ClipboardData(text: csv));
  }

  Future<bool> _blockIfDemo() async {
    if (!widget.store.usingDemoRides) {
      return false;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _parsed = null;
      _plan = null;
      _message = l10n.demoRequiresSyncMessage;
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
    final l10n = AppLocalizations.of(context);
    setState(() {
      _parsed = null;
      _plan = null;
      _message = l10n.importedSettings(
        result.updated,
        result.created,
        result.grouped == 0 ? '' : l10n.groupsCountPreview(result.grouped),
      );
    });
  }
}
