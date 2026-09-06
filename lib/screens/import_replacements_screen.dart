import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/seed.dart';
import '../domain/replacement_csv.dart';
import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class ImportReplacementsScreen extends StatefulWidget {
  const ImportReplacementsScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<ImportReplacementsScreen> createState() =>
      _ImportReplacementsScreenState();
}

class _ImportReplacementsScreenState extends State<ImportReplacementsScreen> {
  final _csv = TextEditingController();
  ReplacementCsvParseResult? _parsed;
  ReplacementImportPlan? _plan;
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
          appBar: AppBar(title: Text(l10n.recordsCsv)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                gearLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.store.settings.showUserHelp) ...[
                const SizedBox(height: 8),
                Text(
                  canManage ? l10n.recordsCsvScope : l10n.csvNeedGear,
                  style: userHelpStyle(context),
                ),
              ] else if (!canManage) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.csvNeedGear,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              if (widget.store.settings.showUserHelp) ...[
                Text(l10n.csvCopyHint),
                const SizedBox(height: 8),
              ],
              OutlinedButton(
                onPressed: canManage ? _export : null,
                child: Text(l10n.exportCurrentRecords),
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
                  hintText: l10n.recordsCsvHint,
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
                          _csv.text = replacementCsvExample(
                            defaultParts(locale: widget.store.catalogLocale)
                                .map((part) => part.registeredName)
                                .toList(),
                            startDate: widget.store.partOriginOn,
                            header: l10n.recordsCsvHint,
                          );
                          _parsed = null;
                          _plan = null;
                          _message = null;
                        });
                      }
                    : null,
                child: Text(l10n.insertExample),
              ),
              if (widget.store.settings.showUserHelp) ...[
                const SizedBox(height: 8),
                Text(l10n.recordsCsvHelp, style: userHelpStyle(context)),
              ],
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
                  '${l10n.replaceCount(_plan!.toAdd.length)}'
                  '${_plan!.duplicates.isEmpty ? '' : l10n.skipCsvDuplicatesPreview(_plan!.duplicates.length)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_plan!.toAdd.isEmpty && _plan!.duplicates.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(l10n.noNewRows),
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
    final gearId = widget.store.settings.selectedGearId;
    final csv = exportReplacementCsv(
      parts: widget.store.parts,
      replacements: widget.store.replacements,
      gearId: gearId,
      header: l10n.recordsCsvHint,
    );
    final count = widget.store.replacements.where((item) {
      return item.gearId == gearId && widget.store.partById(item.partId) != null;
    }).length;
    setState(() {
      _csv.text = csv;
      _parsed = null;
      _plan = null;
      _message = count == 0
          ? l10n.exportedEmptyRecords
          : l10n.exportedCount(count);
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
    if (_csv.text.trim().isEmpty) {
      setState(() {
        _parsed = null;
        _plan = null;
        _message = null;
      });
      return;
    }
    final parsed = parseReplacementCsv(
      _csv.text,
      startDate: widget.store.partOriginOn,
    );
    ReplacementImportPlan? plan;
    if (parsed.errors.isEmpty) {
      plan = planReplacementImport(
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
    final result = await widget.store.importReplacementPlan(plan);
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _parsed = null;
      _plan = null;
      _message =
          '${l10n.importedRecords(result.added)}'
          '${result.skippedDuplicates == 0 ? '' : l10n.skippedDuplicates(result.skippedDuplicates)}';
    });
  }
}
