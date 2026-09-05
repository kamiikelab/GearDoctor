import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';

class DisplayGroupScreen extends StatefulWidget {
  const DisplayGroupScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<DisplayGroupScreen> createState() => _DisplayGroupScreenState();
}

class _DisplayGroupScreenState extends State<DisplayGroupScreen> {
  bool _combine = true;
  final List<String> _picked = [];
  String? _frontId;
  final _name = TextEditingController();
  String? _dissolveId;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.groupTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              if (widget.store.settings.showUserHelp) ...[
                Text(l10n.groupHelp, style: userHelpStyle(context)),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: SelectTile(
                      selected: _combine,
                      title: l10n.groupTogether,
                      onTap: () => setState(() => _combine = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectTile(
                      selected: !_combine,
                      title: l10n.groupSplit,
                      onTap: () => setState(() => _combine = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_combine) _combineForm() else _separateForm(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
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

  Widget _combineForm() {
    final l10n = AppLocalizations.of(context);
    final candidates = widget.store.ungroupedParts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.pickTwoParts, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        if (candidates.length < 2) Text(l10n.groupNeedTwo),
        for (final part in candidates) ...[
          SelectTile(
            selected: _picked.contains(part.id),
            title: _picked.contains(part.id)
                ? '${part.registeredName}${l10n.pickedSuffix}'
                : part.registeredName,
            onTap: () => _toggle(part.id),
          ),
          const SizedBox(height: 8),
        ],
        Text(l10n.pickFront, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final id in _picked) ...[
              Expanded(
                child: SelectTile(
                  selected: _frontId == id,
                  title: l10n.partIsFront(_nameOf(id)),
                  onTap: () => setState(() => _frontId = id),
                ),
              ),
              if (id != _picked.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.groupedNameStep, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        AppTextField(
          controller: _name,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: l10n.groupNameHint,
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (widget.store.settings.showUserHelp) ...[
          const SizedBox(height: 4),
          Text(
            l10n.groupPreview(
              _name.text.isEmpty ? l10n.groupNamePlaceholder : _name.text,
            ),
            style: userHelpStyle(context),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saveCombine,
          child: Text(l10n.groupTogether),
        ),
      ],
    );
  }

  Widget _separateForm() {
    final l10n = AppLocalizations.of(context);
    final groups = widget.store.groups;
    if (groups.isEmpty) {
      return Text(l10n.noGroups);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.groupToRemove, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        for (final group in groups) ...[
          SelectTile(
            selected: _dissolveId == group.id,
            title: group.displayName,
            subtitle:
                '${_nameOf(group.rearPartId)} / ${_nameOf(group.frontPartId)}',
            onTap: () => setState(() => _dissolveId = group.id),
          ),
          const SizedBox(height: 8),
        ],
        if (_selectedGroup != null) ...[
          Text(l10n.stopGrouping(_selectedGroup!.displayName)),
          const SizedBox(height: 8),
          Text(l10n.afterSplit, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            _nameOf(_selectedGroup!.rearPartId),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            _nameOf(_selectedGroup!.frontPartId),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.groupSplitHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
        ],
        FilledButton(
          onPressed: _saveSeparate,
          child: Text(l10n.groupSplit),
        ),
      ],
    );
  }

  DisplayGroup? get _selectedGroup {
    for (final group in widget.store.groups) {
      if (group.id == _dissolveId) {
        return group;
      }
    }
    return null;
  }

  String _nameOf(String partId) {
    return widget.store.partById(partId)?.registeredName ?? partId;
  }

  void _toggle(String id) {
    setState(() {
      if (_picked.contains(id)) {
        _picked.remove(id);
      } else if (_picked.length >= 2) {
        _picked
          ..removeAt(0)
          ..add(id);
      } else {
        _picked.add(id);
      }
      if (_frontId != null && !_picked.contains(_frontId)) {
        _frontId = _picked.isEmpty ? null : _picked.first;
      }
      if (_frontId == null && _picked.isNotEmpty) {
        _frontId = _picked.first;
      }
    });
  }

  Future<void> _saveCombine() async {
    final l10n = AppLocalizations.of(context);
    if (_picked.length != 2 || _frontId == null) {
      setState(() => _error = l10n.pickTwoAndFront);
      return;
    }
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.enterGroupName);
      return;
    }
    final rearId = _picked.firstWhere((id) => id != _frontId);
    final front = widget.store.partById(_frontId!);
    final rear = widget.store.partById(rearId);
    if (front == null || rear == null) {
      setState(() => _error = l10n.partsNotFound);
      return;
    }
    if (front.cycle != rear.cycle) {
      setState(() => _error = l10n.sameCycleOnly);
      return;
    }
    await widget.store.combineDisplay(
      frontPartId: front.id,
      rearPartId: rear.id,
      displayName: name,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveSeparate() async {
    final l10n = AppLocalizations.of(context);
    final group = _selectedGroup;
    if (group == null) {
      setState(() => _error = l10n.selectGroupToSplit);
      return;
    }
    await widget.store.dissolveGroup(group.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
