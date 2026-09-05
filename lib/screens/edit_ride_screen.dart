import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/dates.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class EditRideScreen extends StatefulWidget {
  const EditRideScreen({
    super.key,
    required this.store,
    required this.rideId,
  });

  final AppStore store;
  final String rideId;

  @override
  State<EditRideScreen> createState() => _EditRideScreenState();
}

class _EditRideScreenState extends State<EditRideScreen> {
  DateTime? _date;
  late final TextEditingController _km;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final current = _find();
    _date = current == null ? null : dateOnly(current.startedOn);
    _km = TextEditingController(
      text: current == null ? '' : _kmFieldText(current.distanceKm),
    );
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
        final ride = _find();
        if (ride == null || _date == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editRide)),
            body: Center(child: Text(l10n.rideNotFound)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editRide)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(l10n.rideDate, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: _busy ? null : () => _pickDate(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(formatDate(_date!)),
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
                onPressed: _busy ? null : _save,
                child: Text(l10n.save),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => _delete(ride),
                child: Text(l10n.deleteThisRide),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        );
      },
    );
  }

  Ride? _find() {
    for (final item in widget.store.rides) {
      if (item.id == widget.rideId) {
        return item;
      }
    }
    return null;
  }

  String _kmFieldText(double km) {
    if (km == km.roundToDouble()) {
      return km.round().toString();
    }
    return km.toString();
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = _date ?? widget.store.now;
    final picked = await showAppDatePicker(
      context: context,
      initialDate: initial,
      lastDate: widget.store.now,
      currentDate: widget.store.now,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _date = DateTime.utc(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _save() async {
    final on = _date;
    if (on == null) {
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
      await widget.store.updateManualRide(
        id: widget.rideId,
        on: on,
        distanceKm: km,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
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

  Future<void> _delete(Ride ride) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteRideTitle),
          content: Text(
            l10n.deleteRideConfirm(
              formatDate(ride.startedOn),
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
      await widget.store.deleteManualRide(widget.rideId);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
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
