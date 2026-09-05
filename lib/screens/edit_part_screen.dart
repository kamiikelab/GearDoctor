import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/dates.dart';
import '../domain/recommendations.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class EditPartScreen extends StatefulWidget {
  const EditPartScreen({super.key, required this.store, this.partId});

  final AppStore store;
  final String? partId;

  @override
  State<EditPartScreen> createState() => _EditPartScreenState();
}

class _EditPartScreenState extends State<EditPartScreen> {
  late final TextEditingController _name;
  late final TextEditingController _custom;
  late final TextEditingController _threshold;
  late CycleKind _cycle;
  late LimitMode _mode;
  late int _recommended;
  String? _error;

  bool get _isNew => widget.partId == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.partId == null
        ? null
        : widget.store.partById(widget.partId!);
    _name = TextEditingController(text: existing?.registeredName ?? '');
    _cycle = existing?.cycle ?? CycleKind.distance;
    _mode = existing?.limitMode ?? LimitMode.recommended;
    _recommended =
        existing?.recommendedLimit ??
        recommendedLimitFor(_name.text, _cycle);
    _custom = TextEditingController(
      text: (existing?.customLimit ?? _recommended).toString(),
    );
    _threshold = TextEditingController(
      text: (existing?.thresholdPct ?? 80).toString(),
    );
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _custom.dispose();
    _threshold.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!_isNew) {
      return;
    }
    setState(() {
      _recommended = recommendedLimitFor(_name.text, _cycle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = unitLabelOf(_cycle, l10n);
    final existing = widget.partId == null
        ? null
        : widget.store.partById(widget.partId!);
    final previous = existing == null
        ? null
        : widget.store.previousCycleOf(
            existing.copyWith(cycle: _cycle),
          );
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l10n.addPart : l10n.editPart)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text(l10n.registeredName, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          AppTextField(
            controller: _name,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.registeredNameHint,
            ),
          ),
          if (widget.store.settings.showUserHelp) ...[
            const SizedBox(height: 4),
            Text(l10n.registeredNameHelp, style: userHelpStyle(context)),
          ],
          if (_isNew) ...[
            const SizedBox(height: 4),
            Text(
              widget.store.oldestSelectedRideOn == null
                  ? l10n.firstReplacementNoRide
                  : l10n.firstReplacementWithRide(
                      formatDate(widget.store.oldestSelectedRideOn!),
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.cycle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            l10n.cycleHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectTile(
                  selected: _cycle == CycleKind.distance,
                  title: l10n.cycleDistance,
                  onTap: () => _setCycle(CycleKind.distance),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SelectTile(
                  selected: _cycle == CycleKind.months,
                  title: l10n.cycleMonths,
                  onTap: () => _setCycle(CycleKind.months),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.limit, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SelectTile(
            selected: _mode == LimitMode.recommended,
            title: l10n.limitRecommended(formatAmount(_recommended), unit),
            subtitle: widget.store.settings.showUserHelp
                ? l10n.limitRecommendedHelp
                : null,
            helpSubtitle: true,
            onTap: () => setState(() => _mode = LimitMode.recommended),
          ),
          const SizedBox(height: 8),
          SelectTile(
            selected: _mode == LimitMode.previousCycle,
            title: previous == null
                ? l10n.limitAutoEmpty
                : l10n.limitAuto(formatAmount(previous), unit),
            subtitle: widget.store.settings.showUserHelp
                ? l10n.limitAutoHelp
                : null,
            helpSubtitle: true,
            onTap: () => setState(() => _mode = LimitMode.previousCycle),
          ),
          const SizedBox(height: 8),
          SelectTile(
            selected: _mode == LimitMode.custom,
            title: l10n.limitCustom(
              _custom.text.isEmpty ? l10n.emDash : _custom.text,
              unit,
            ),
            subtitle: widget.store.settings.showUserHelp
                ? l10n.limitCustomHelp
                : null,
            helpSubtitle: true,
            onTap: () => setState(() => _mode = LimitMode.custom),
          ),
          if (_mode == LimitMode.custom) ...[
            const SizedBox(height: 8),
            AppTextField(
              controller: _custom,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixText: unit,
                hintText: l10n.customValue,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.threshold, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          AppTextField(
            controller: _threshold,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
          if (!_isNew) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _delete,
              child: Text(l10n.deleteThisPart),
            ),
          ],
        ],
      ),
    );
  }

  void _setCycle(CycleKind cycle) {
    setState(() {
      _cycle = cycle;
      _recommended = _isNew
          ? recommendedLimitFor(_name.text, cycle)
          : _recommendedForExisting(cycle);
      _custom.text = _recommended.toString();
    });
  }

  int _recommendedForExisting(CycleKind cycle) {
    final existing = widget.store.partById(widget.partId!);
    if (existing != null && existing.cycle == cycle) {
      return existing.recommendedLimit;
    }
    return recommendedLimitFor(_name.text, cycle);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    var custom = int.tryParse(_custom.text);
    final threshold = int.tryParse(_threshold.text);
    if (name.isEmpty) {
      setState(() => _error = l10n.nameRequired);
      return;
    }
    if (_mode == LimitMode.custom && (custom == null || custom <= 0)) {
      setState(() => _error = l10n.customLimitInvalid);
      return;
    }
    custom ??= _recommended;
    if (custom <= 0) {
      custom = _recommended;
    }
    if (threshold == null || threshold < 1 || threshold > 100) {
      setState(() => _error = l10n.thresholdInvalid);
      return;
    }
    final existing = widget.partId == null
        ? null
        : widget.store.partById(widget.partId!);
    final part = Part(
      id: existing?.id ?? widget.store.newId('p'),
      gearId: existing?.gearId ?? widget.store.settings.selectedGearId ?? '',
      registeredName: name,
      cycle: _cycle,
      limitMode: _mode,
      recommendedLimit: _recommended,
      customLimit: custom,
      thresholdPct: threshold,
      sortOrder: existing?.sortOrder ?? widget.store.nextSortOrder(),
    );
    if (_isNew && widget.store.usingDemoRides) {
      setState(() => _error = l10n.demoRequiresSyncMessage);
      await showDemoRequiresSyncDialog(context);
      return;
    }
    if (_isNew && !widget.store.canManageRecords) {
      setState(() => _error = l10n.selectGearFirstPart);
      return;
    }
    await widget.store.savePart(part, isNew: _isNew);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    if (widget.store.usingDemoRides) {
      await showDemoRequiresSyncDialog(context);
      return;
    }
    final part = widget.store.partById(widget.partId!);
    if (part == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deletePartTitle),
          content: Text(l10n.deletePartConfirm(part.registeredName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteThisPart),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.store.deletePart(part.id);
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
