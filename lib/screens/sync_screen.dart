import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../domain/dates.dart';
import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../strava/strava_oauth.dart';
import '../widgets/widgets.dart';
import 'ride_history_screen.dart';
import 'strava_connect_screen.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String? _message;
  bool _busy = false;
  late DateTime _rideDate;
  late final TextEditingController _km;
  final _http = http.Client();

  @override
  void initState() {
    super.initState();
    _rideDate = widget.store.now;
    _km = TextEditingController();
  }

  @override
  void dispose() {
    _km.dispose();
    _http.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final connected = widget.store.settings.stravaConnected;
        final from = widget.store.settings.lastSyncFrom;
        final to = widget.store.settings.lastSyncAt;
        final hasStart = from != null;
        final gear = widget.store.selectedGear;
        final gearName = gear == null ? l10n.gearUnselected : gear.name;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.syncTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                l10n.manualRideSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SelectedGearHeading(name: gearName),
              const SizedBox(height: 12),
              Text(l10n.rideDate, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: _busy ? null : _pickRideDate,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(formatDate(_rideDate)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.rideDistance,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              AppTextField(
                controller: _km,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixText: l10n.unitKm,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _recordRide,
                child: Text(l10n.logReplacement),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                RideHistoryScreen(store: widget.store),
                          ),
                        );
                      },
                child: Text(l10n.viewRides),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.importFromStrava,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.store.settings.showUserHelp) ...[
                const SizedBox(height: 4),
                Text(l10n.stravaHint, style: userHelpStyle(context)),
              ],
              const SizedBox(height: 8),
              _RangeSummary(from: from, to: to),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: connected && !_busy ? _syncForward : null,
                child: Text(l10n.sync1year),
              ),
              if (widget.store.settings.showUserHelp) ...[
                const SizedBox(height: 16),
                Text(l10n.startDateHelp, style: userHelpStyle(context)),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : _changeStartDate,
                child: Text(
                  hasStart ? l10n.changeStartDate : l10n.specifyStartDate,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          StravaConnectScreen(store: widget.store),
                    ),
                  );
                },
                child: Text(l10n.stravaConnect),
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

  Future<void> _pickRideDate() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _rideDate,
      lastDate: widget.store.now,
      currentDate: widget.store.now,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _rideDate = DateTime.utc(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _recordRide() async {
    final l10n = AppLocalizations.of(context);
    if (widget.store.selectedGear == null) {
      setState(() => _message = l10n.needGearForRide);
      return;
    }
    final km = double.tryParse(_km.text.trim().replaceAll(',', ''));
    if (km == null || km <= 0) {
      setState(() => _message = l10n.invalidRideDistance);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.store.addManualRide(on: _rideDate, distanceKm: km);
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _message = l10n.rideRecorded;
        _km.clear();
        _rideDate = widget.store.now;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _message = '$error';
      });
    }
  }

  Future<void> _syncForward() async {
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
        months: 12,
        client: _http,
      );
      if (!mounted) {
        return;
      }
      final newest = summary.newestRideOn;
      setState(() {
        _busy = false;
        _km.clear();
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
      initialDate: widget.store.settings.lastSyncFrom ?? widget.store.now,
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
    final confirmed = await _confirm(
      title: l10n.changeStartTitle,
      body: l10n.changeStartConfirm(formatDate(next)),
      action: l10n.deleteAndContinue,
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

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String action,
  }) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action),
            ),
          ],
        );
      },
    );
  }
}

class _RangeSummary extends StatelessWidget {
  const _RangeSummary({
    required this.from,
    required this.to,
  });

  final DateTime? from;
  final DateTime? to;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = from == null && to == null
        ? l10n.emDash
        : l10n.syncRange(
            from == null ? l10n.emDash : formatDate(from!),
            to == null ? l10n.emDash : formatDate(to!),
          );
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dataRange, style: fieldLabelStyle(context)),
          const SizedBox(height: 6),
          Text(range, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
