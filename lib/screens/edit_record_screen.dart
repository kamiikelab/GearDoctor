import 'package:flutter/material.dart';

import '../domain/dates.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class EditRecordScreen extends StatefulWidget {
  const EditRecordScreen({
    super.key,
    required this.store,
    required this.partId,
    required this.replacementId,
  });

  final AppStore store;
  final String partId;
  final String replacementId;

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  DateTime? _date;
  late final TextEditingController _memo;

  @override
  void initState() {
    super.initState();
    final current = _find();
    _date = current?.replacedOn;
    _memo = TextEditingController(text: current?.memo ?? '');
  }

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final part = widget.store.partById(widget.partId);
        final replacement = _find();
        if (part == null || replacement == null || _date == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editRecord)),
            body: Center(child: Text(l10n.recordNotFound)),
          );
        }
        final row = widget.store.historyOf(part).firstWhere(
          (item) => item.replacement.id == replacement.id,
        );
        final name = widget.store.titleOf(part);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editRecord)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                '$name · ${formatUsed(row.used, CycleKind.distance, l10n, demo: widget.store.usingDemoRides)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(l10n.replacedOn, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () => _pickDate(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(formatDate(_date!)),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.memo, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              AppTextField(
                controller: _memo,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.memoHint,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.editRecordHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await widget.store.updateReplacement(
                    replacement.copyWith(replacedOn: _date, memo: _memo.text),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n.save),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final lastOne =
                      widget.store.replacementsFor(part.id).length <= 1;
                  if (lastOne) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.cannotDeleteLastRecord)),
                      );
                    }
                    return;
                  }
                  await widget.store.deleteReplacement(replacement.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n.deleteThisRecord),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        );
      },
    );
  }

  Replacement? _find() {
    for (final item in widget.store.replacementsFor(widget.partId)) {
      if (item.id == widget.replacementId) {
        return item;
      }
    }
    return null;
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = _date ?? widget.store.now;
    final picked = await showAppDatePicker(
      context: context,
      initialDate: initial,
      lastDate: widget.store.now,
      currentDate: widget.store.now,
    );
    if (picked != null) {
      setState(() => _date = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }
}
