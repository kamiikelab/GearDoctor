import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class AddGearScreen extends StatefulWidget {
  const AddGearScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<AddGearScreen> createState() => _AddGearScreenState();
}

class _AddGearScreenState extends State<AddGearScreen> {
  final _name = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addBike)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text(l10n.bikeName, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          AppTextField(
            controller: _name,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.bikeNameHint,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(l10n.addBikeAction),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.bikeNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.store.addGear(name);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = '$error';
      });
    }
  }
}
