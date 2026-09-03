import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';
import 'display_group_screen.dart';
import 'edit_part_screen.dart';
import 'import_replacements_screen.dart';
import 'import_settings_screen.dart';
import 'add_gear_screen.dart';

class GearScreen extends StatelessWidget {
  const GearScreen({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final selected = store.selectedGear;
        final selectedName = selected == null
            ? l10n.gearUnselected
            : demoGearLabel(
                selected.name,
                l10n,
                demo: store.usingDemoRides && isDemoGearId(selected.id),
              );
        final canManage = store.canManageRecords;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.gear)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                selectedName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.gearBikesHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (store.usingDemoRides) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.gearDemoCsvHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              if (store.gears.isEmpty) ...[
                Text(l10n.gearEmptyHint),
                const SizedBox(height: 8),
              ] else ...[
                for (final gear in store.gears) ...[
                  SelectTile(
                    selected: store.settings.selectedGearId == gear.id,
                    title: demoGearLabel(
                      gear.name,
                      l10n,
                      demo: store.usingDemoRides && isDemoGearId(gear.id),
                      selected: store.settings.selectedGearId == gear.id,
                    ),
                    onTap: () => store.selectGear(gear.id),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddGearScreen(store: store),
                    ),
                  );
                },
                child: Text(l10n.addBike),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: selected == null
                    ? null
                    : () => _deleteBike(context, store, selected),
                child: Text(l10n.deleteBike),
              ),
              const SizedBox(height: 8),
              if (!canManage && store.gears.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.gearSelectHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              OutlinedButton(
                onPressed: () {
                  if (store.usingDemoRides) {
                    showDemoRequiresSyncDialog(context);
                    return;
                  }
                  if (!canManage) {
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditPartScreen(store: store),
                    ),
                  );
                },
                child: Text(l10n.addPart),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  if (store.usingDemoRides) {
                    showDemoRequiresSyncDialog(context);
                    return;
                  }
                  if (!canManage) {
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ImportReplacementsScreen(store: store),
                    ),
                  );
                },
                child: Text(l10n.recordsCsv),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  if (store.usingDemoRides) {
                    showDemoRequiresSyncDialog(context);
                    return;
                  }
                  if (!canManage) {
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ImportSettingsScreen(store: store),
                    ),
                  );
                },
                child: Text(l10n.settingsCsv),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: canManage
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DisplayGroupScreen(store: store),
                          ),
                        );
                      }
                    : null,
                child: Text(l10n.displayGroups),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteBike(
    BuildContext context,
    AppStore store,
    Gear gear,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (!isUserDeletableGear(gear.id)) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.deleteBikeTitle),
            content: Text(l10n.cannotDeleteStravaBike),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteBikeTitle),
          content: Text(l10n.deleteBikeConfirm(gear.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteBike),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await store.deleteGear(gear.id);
  }
}
