import 'package:flutter/material.dart';

import '../domain/dates.dart';
import '../domain/usage.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';
import 'edit_part_screen.dart';
import 'edit_record_screen.dart';
import 'replace_screen.dart';

class PartDetailScreen extends StatelessWidget {
  const PartDetailScreen({
    super.key,
    required this.store,
    required this.partId,
  });

  final AppStore store;
  final String partId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final part = store.partById(partId);
        if (part == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.partDetail)),
            body: Center(child: Text(l10n.partNotFound)),
          );
        }
        final used = store.usedOf(part);
        final limit = store.limitOf(part);
        final last = latestReplacement(store.replacementsFor(part.id));
        final percent = usagePercent(used, limit);
        final status = wearStatus(used, limit, part.thresholdPct);
        final modeLabel = store.limitModeLabelOf(part, l10n);
        final heading = part.cycle == CycleKind.months
            ? l10n.afterMonths
            : l10n.afterDistance;
        return Scaffold(
          appBar: AppBar(title: Text(store.titleOf(part))),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Text(heading, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(
                formatElapsedAndDue(
                  used,
                  limit,
                  part.cycle,
                  l10n,
                  modeLabel: modeLabel,
                  demo: store.usingDemoRides,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              UsageBar(
                used: used,
                limit: limit,
                status: status,
                topLeft: l10n.statusPercent(
                  percent,
                  wearStatusLabel(status, l10n),
                ),
                topRight: l10n.thresholdPct(part.thresholdPct),
              ),
              const SizedBox(height: 12),
              Text(
                last == null
                    ? l10n.lastReplacementNone
                    : l10n.lastReplacement(formatDate(last.replacedOn)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: store.canManageRecords
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ReplaceScreen(
                                    store: store,
                                    partId: part.id,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(l10n.replaced),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                EditPartScreen(store: store, partId: part.id),
                          ),
                        );
                      },
                      child: Text(l10n.edit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ReplacementHistoryTable(
                part: part,
                rows: store.historyOf(part),
                todayUsed: store.gearKmThrough(store.now),
                demoDistance: store.usingDemoRides,
                showUserHelp: store.settings.showUserHelp,
                onRowTap: (row) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditRecordScreen(
                        store: store,
                        partId: part.id,
                        replacementId: row.replacement.id,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
