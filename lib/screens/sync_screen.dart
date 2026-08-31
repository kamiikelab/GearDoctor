import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/dates.dart';
import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../strava/strava_oauth.dart';
import '../widgets/widgets.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String? _message;
  bool _busy = false;
  final _http = http.Client();

  @override
  void dispose() {
    _http.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final from = widget.store.settings.lastSyncFrom;
        final to = widget.store.newestSyncedOn;
        final hasStart = from != null;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.syncTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RangeSummary(
                from: from,
                to: to,
                demo: widget.store.usingDemoRides,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.untilDateHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(l10n.syncManualHelp),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : () => _syncForward(months: 3),
                child: Text(l10n.sync3months),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => _syncForward(months: 6),
                child: Text(l10n.sync6months),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => _syncForward(months: 12),
                child: Text(l10n.sync1year),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.startDateHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : _changeStartDate,
                child: Text(
                  hasStart ? l10n.changeStartDate : l10n.specifyStartDate,
                ),
              ),
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

  Future<void> _syncForward({required int months}) async {
    final l10n = AppLocalizations.of(context);
    if (widget.store.settings.lastSyncFrom == null) {
      setState(() => _message = l10n.needStartDate);
      return;
    }
    if (!widget.store.settings.stravaConnected) {
      setState(() => _message = l10n.needConnect);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final summary = await widget.store.syncForward(
        months: months,
        client: _http,
      );
      if (!mounted) {
        return;
      }
      final newest = summary.newestRideOn;
      setState(() {
        _busy = false;
        _message = newest == null
            ? l10n.syncFetchedEmpty(
                formatDate(summary.from),
                formatDate(summary.to),
              )
            : l10n.syncFetched(
                formatDate(summary.from),
                formatDate(summary.to),
                summary.savedCount,
                formatDate(newest),
              );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _message = error is StravaAuthException ? error.message : '$error';
      });
    }
  }

  Future<void> _changeStartDate() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppDatePicker(
      context: context,
      initialDate:
          widget.store.settings.lastSyncFrom ?? widget.store.now,
      lastDate: widget.store.now,
      currentDate: widget.store.now,
    );
    if (picked == null || !mounted) {
      return;
    }
    final next = DateTime.utc(picked.year, picked.month, picked.day);
    final current = widget.store.settings.lastSyncFrom;
    if (current != null && dateOnly(current) == next) {
      setState(() => _message = l10n.startDateUnchanged);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.changeStartTitle),
          content: Text(l10n.changeStartConfirm(formatDate(next))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteAndContinue),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    await widget.store.changeSyncStart(next);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _message = AppLocalizations.of(context).startDateChanged(formatDate(next));
    });
  }
}

class _RangeSummary extends StatelessWidget {
  const _RangeSummary({required this.from, required this.to, required this.demo});

  final DateTime? from;
  final DateTime? to;
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (from == null && to == null) {
      return Text(l10n.notSynced, style: Theme.of(context).textTheme.titleMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dataRange, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(
          markDemo(
            l10n.stravaStartDate(from == null ? l10n.emDash : formatDate(from!)),
            l10n,
            demo: demo,
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          markDemo(
            l10n.untilDate(to == null ? l10n.emDash : formatDate(to!)),
            l10n,
            demo: demo,
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
