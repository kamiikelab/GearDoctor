import 'package:flutter/material.dart';

import '../domain/dates.dart';
import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';
import 'edit_record_screen.dart';

class ReplaceScreen extends StatefulWidget {
  const ReplaceScreen({super.key, required this.store, required this.partId});

  final AppStore store;
  final String partId;

  @override
  State<ReplaceScreen> createState() => _ReplaceScreenState();
}

class _ReplaceScreenState extends State<ReplaceScreen> {
  late DateTime _date;
  final _memo = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = widget.store.now;
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
        if (part == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.recordReplace)),
            body: Center(child: Text(l10n.partNotFound)),
          );
        }
        final name = widget.store.titleOf(part).replaceAll(' · ', '（') +
            (widget.store.groupOf(part.id) == null ? '' : '）');
        final history = widget.store.historyOf(part);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.recordReplace)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                l10n.replaceResetHelp(name, usageNounOf(part.cycle, l10n)),
              ),
              const SizedBox(height: 16),
              Text(l10n.replacedOn, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () => _pickDate(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(formatDate(_date)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.replaceDateHelp,
                style: Theme.of(context).textTheme.bodySmall,
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
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.store.canManageRecords
                    ? () async {
                        await widget.store.addReplacement(
                          partId: part.id,
                          replacedOn: _date,
                          memo: _memo.text,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                child: Text(l10n.logReplacement),
              ),
              const SizedBox(height: 20),
              ReplacementHistoryTable(
                part: part,
                rows: history,
                todayUsed: widget.store.gearKmThrough(widget.store.now),
                demoDistance: widget.store.usingDemoRides,
                onRowTap: (row) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditRecordScreen(
                        store: widget.store,
                        partId: widget.partId,
                        replacementId: row.replacement.id,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
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

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _date,
      lastDate: widget.store.now,
      currentDate: widget.store.now,
    );
    if (picked != null) {
      setState(() => _date = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }
}
