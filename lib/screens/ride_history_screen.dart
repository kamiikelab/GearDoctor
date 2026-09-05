import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/seed.dart';
import '../domain/dates.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  String? _editingRideId;
  DateTime? _rideDate;
  late final TextEditingController _km;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _km = TextEditingController();
  }

  @override
  void dispose() {
    _km.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final gear = widget.store.selectedGear;
        final gearName = gear == null ? l10n.gearUnselected : gear.name;
        final rides = widget.store.selectedGearRides;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.gearRidesSection)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                l10n.selectedGearLine(gearName),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.rideHistoryHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (rides.isEmpty)
                Text(
                  l10n.noGearRides,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                RideHistoryTable(
                  rides: rides,
                  onRowTap: (ride) {
                    if (isManualRideId(ride.id)) {
                      _startEdit(ride);
                    }
                  },
                ),
              if (_editingRideId != null) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.rideDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: _busy ? null : _pickRideDate,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(formatDate(_rideDate ?? widget.store.now)),
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
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _saveRide,
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy ? null : _deleteEditingRide,
                  child: Text(l10n.deleteThisRide),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy ? null : _clearEdit,
                  child: Text(l10n.cancel),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _startEdit(Ride ride) {
    setState(() {
      _editingRideId = ride.id;
      _rideDate = dateOnly(ride.startedOn);
      _km.text = _kmFieldText(ride.distanceKm);
    });
  }

  void _clearEdit() {
    setState(() {
      _editingRideId = null;
      _rideDate = null;
      _km.clear();
    });
  }

  String _kmFieldText(double km) {
    if (km == km.roundToDouble()) {
      return km.round().toString();
    }
    return km.toString();
  }

  Future<void> _pickRideDate() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _rideDate ?? widget.store.now,
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

  Future<void> _saveRide() async {
    final id = _editingRideId;
    final on = _rideDate;
    if (id == null || on == null) {
      return;
    }
    final km = double.tryParse(_km.text.trim().replaceAll(',', ''));
    final l10n = AppLocalizations.of(context);
    if (km == null || km <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidRideDistance)));
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.store.updateManualRide(id: id, on: on, distanceKm: km);
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      _clearEdit();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _deleteEditingRide() async {
    final id = _editingRideId;
    if (id == null) {
      return;
    }
    Ride? ride;
    for (final item in widget.store.selectedGearRides) {
      if (item.id == id) {
        ride = item;
        break;
      }
    }
    if (ride == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteRideTitle),
          content: Text(
            l10n.deleteRideConfirm(
              formatDate(ride!.startedOn),
              formatAmount(ride.distanceKm),
            ),
          ),
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
    setState(() => _busy = true);
    try {
      await widget.store.deleteManualRide(id);
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      _clearEdit();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}
