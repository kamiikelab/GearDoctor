import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../domain/dates.dart';
import '../domain/usage.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';

export 'app_text_field.dart';

TextStyle? fieldLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleSmall;
}

TextStyle? userHelpStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    required this.child,
    this.expand = true,
  });

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child,
      ),
    );
    if (!expand) {
      return panel;
    }
    return SizedBox(width: double.infinity, child: panel);
  }
}

class SelectedGearHeading extends StatelessWidget {
  const SelectedGearHeading({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectedGear, style: fieldLabelStyle(context)),
          const SizedBox(height: 4),
          Text(name, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

String formatAmount(num value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return value.round() < 0 ? '-$buffer' : buffer.toString();
}

String unitLabelOf(CycleKind cycle, AppLocalizations l10n) {
  return cycle == CycleKind.months ? l10n.unitMonths : l10n.unitKm;
}

String usageNounOf(CycleKind cycle, AppLocalizations l10n) {
  return cycle == CycleKind.months ? l10n.usageMonths : l10n.usageDistance;
}

String wearStatusLabel(WearStatus status, AppLocalizations l10n) {
  return switch (status) {
    WearStatus.overdue => l10n.statusOverdue,
    WearStatus.soon => l10n.statusSoon,
    WearStatus.ok => l10n.statusOk,
  };
}

String formatUsed(
  num value,
  CycleKind cycle,
  AppLocalizations l10n, {
  bool demo = false,
}) {
  final text = '${formatAmount(value)}${unitLabelOf(cycle, l10n)}';
  if (demo && cycle == CycleKind.distance) {
    return '$text${l10n.demoSuffix}';
  }
  return text;
}

String formatElapsedAndDue(
  num used,
  int limit,
  CycleKind cycle,
  AppLocalizations l10n, {
  String? modeLabel,
  bool demo = false,
}) {
  final buffer = StringBuffer(
    '${formatAmount(used)} / ${formatAmount(limit)} ${unitLabelOf(cycle, l10n)}',
  );
  if (modeLabel != null && modeLabel.isNotEmpty) {
    buffer.write(' $modeLabel');
  }
  if (demo && cycle == CycleKind.distance) {
    buffer.write(l10n.demoSuffix);
  }
  return buffer.toString();
}

String formatTodayUsed(
  num value,
  CycleKind cycle,
  AppLocalizations l10n, {
  bool demo = false,
}) {
  return '${formatUsed(value, cycle, l10n, demo: demo)}${l10n.todaySuffix}';
}

String markDemo(String text, AppLocalizations l10n, {required bool demo}) {
  if (!demo) {
    return text;
  }
  return '$text${l10n.demoSuffix}';
}

String demoGearLabel(
  String name,
  AppLocalizations l10n, {
  required bool demo,
  bool selected = false,
}) {
  if (demo && selected) {
    return '$name${l10n.demoSelectedSuffix}';
  }
  if (demo) {
    return '$name${l10n.demoSuffix}';
  }
  if (selected) {
    return '$name${l10n.selectedSuffix}';
  }
  return name;
}

Future<void> showDemoRequiresSyncDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.demoRequiresSyncTitle),
        content: Text(l10n.demoRequiresSyncMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      );
    },
  );
}

/// Material の年グリッドは、年の数が 18 未満だと先頭（2010 など）から表示される。
DateTime appDatePickerFirstDate(DateTime lastDate) {
  const floorYear = 2000;
  const minYears = 18;
  var firstYear = floorYear;
  if (lastDate.year - firstYear + 1 < minYears) {
    firstYear = lastDate.year - minYears + 1;
  }
  return DateTime(firstYear);
}

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime lastDate,
  DateTime? currentDate,
}) {
  final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
  final first = appDatePickerFirstDate(last);
  var initial = DateTime(initialDate.year, initialDate.month, initialDate.day);
  if (initial.isAfter(last)) {
    initial = last;
  }
  if (initial.isBefore(first)) {
    initial = first;
  }
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: last,
    currentDate: currentDate ?? last,
  );
}

Color statusColor(WearStatus status, ColorScheme scheme) {
  return switch (status) {
    WearStatus.overdue => scheme.error,
    WearStatus.soon => const Color(0xFFC56B1A),
    WearStatus.ok => const Color(0xFF2F7D4A),
  };
}

class SelectTile extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.selected,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? scheme.outline : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UsageBar extends StatelessWidget {
  const UsageBar({
    super.key,
    required this.used,
    required this.limit,
    required this.status,
    this.topLeft,
    this.topRight,
  });

  final double used;
  final int limit;
  final WearStatus status;
  final String? topLeft;
  final String? topRight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topLeft != null || topRight != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    topLeft ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  topRight ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  heightFactor: 1,
                  child: ColoredBox(color: statusColor(status, scheme)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SideUsage extends StatelessWidget {
  const SideUsage({
    super.key,
    required this.part,
    required this.used,
    required this.limit,
    this.positionLabel,
    this.modeLabel,
    this.demoDistance = false,
    required this.onTap,
  });

  final Part part;
  final double used;
  final int limit;
  final String? positionLabel;
  final String? modeLabel;
  final bool demoDistance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = usagePercent(used, limit);
    final status = wearStatus(used, limit, part.thresholdPct);
    final statusText = wearStatusLabel(status, l10n);
    final statusLine = positionLabel == null
        ? l10n.statusLine(statusText, percent)
        : l10n.statusLineSide(positionLabel!, statusText, percent);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusLine,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            formatElapsedAndDue(
              used,
              limit,
              part.cycle,
              l10n,
              modeLabel: modeLabel,
              demo: demoDistance,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          UsageBar(used: used, limit: limit, status: status),
        ],
      ),
    );
  }
}

class ReplacementHistoryTable extends StatelessWidget {
  const ReplacementHistoryTable({
    super.key,
    required this.part,
    required this.rows,
    required this.todayUsed,
    this.demoDistance = false,
    this.showUserHelp = true,
    this.onRowTap,
  });

  final Part part;
  final List<HistoryRow> rows;
  final double todayUsed;
  final bool demoDistance;
  final bool showUserHelp;
  final ValueChanged<HistoryRow>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final past = [...rows]
      ..sort(
        (a, b) => b.replacement.replacedOn.compareTo(a.replacement.replacedOn),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.historyTitle, style: Theme.of(context).textTheme.bodySmall),
        if (onRowTap != null && showUserHelp)
          Text(l10n.historyHint, style: userHelpStyle(context)),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.0),
            2: FlexColumnWidth(1.3),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              children: [
                _cell(context, l10n.historyDistanceHeader, header: true),
                _cell(context, l10n.replacedOn, header: true),
                _cell(context, l10n.comment, header: true),
              ],
            ),
            for (final row in past)
              TableRow(
                children: [
                  _cell(
                    context,
                    formatUsed(
                      row.used,
                      CycleKind.distance,
                      l10n,
                      demo: demoDistance,
                    ),
                    onTap: onRowTap == null ? null : () => onRowTap!(row),
                  ),
                  _cell(
                    context,
                    formatDate(row.replacement.replacedOn),
                    onTap: onRowTap == null ? null : () => onRowTap!(row),
                  ),
                  _cell(
                    context,
                    row.replacement.memo.isEmpty
                        ? l10n.emDash
                        : row.replacement.memo,
                    muted: row.replacement.memo.isEmpty,
                    onTap: onRowTap == null ? null : () => onRowTap!(row),
                  ),
                ],
              ),
            TableRow(
              children: [
                _cell(
                  context,
                  formatTodayUsed(
                    todayUsed,
                    CycleKind.distance,
                    l10n,
                    demo: demoDistance,
                  ),
                ),
                _cell(context, ''),
                _cell(context, ''),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    bool header = false,
    bool muted = false,
    VoidCallback? onTap,
  }) {
    return historyTableCell(
      context,
      text,
      header: header,
      muted: muted,
      onTap: onTap,
    );
  }
}

class RideHistoryTable extends StatelessWidget {
  const RideHistoryTable({
    super.key,
    required this.rides,
    this.onRowTap,
  });

  final List<Ride> rides;
  final ValueChanged<Ride>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [...rides]
      ..sort((a, b) => b.startedOn.compareTo(a.startedOn));
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(1.0),
        2: FlexColumnWidth(0.9),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: [
            historyTableCell(context, l10n.rideDate, header: true),
            historyTableCell(context, l10n.rideDistance, header: true),
            historyTableCell(context, l10n.rideKind, header: true),
          ],
        ),
        for (final ride in rows)
          TableRow(
            children: [
              historyTableCell(
                context,
                formatDate(ride.startedOn),
                onTap: _rowTap(ride),
              ),
              historyTableCell(
                context,
                '${formatAmount(ride.distanceKm)} ${l10n.unitKm}',
                onTap: _rowTap(ride),
              ),
              historyTableCell(
                context,
                _kindLabel(l10n, ride.id),
                onTap: _rowTap(ride),
              ),
            ],
          ),
      ],
    );
  }

  VoidCallback? _rowTap(Ride ride) {
    if (onRowTap == null || !isManualRideId(ride.id)) {
      return null;
    }
    return () => onRowTap!(ride);
  }

  String _kindLabel(AppLocalizations l10n, String id) {
    if (isDemoRideId(id)) {
      return l10n.rideKindDemo;
    }
    if (isManualRideId(id)) {
      return l10n.rideKindManual;
    }
    return l10n.rideKindStrava;
  }
}

Widget historyTableCell(
  BuildContext context,
  String text, {
  bool header = false,
  bool muted = false,
  VoidCallback? onTap,
}) {
  final style = header
      ? Theme.of(context).textTheme.bodySmall
      : Theme.of(context).textTheme.bodySmall?.copyWith(
          color: muted
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : null,
        );
  final child = Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, style: style),
  );
  if (onTap == null) {
    return child;
  }
  return TableRowInkWell(onTap: onTap, child: child);
}
