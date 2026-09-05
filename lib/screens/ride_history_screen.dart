import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../widgets/widgets.dart';
import 'edit_ride_screen.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final gear = store.selectedGear;
        final gearName = gear == null ? l10n.gearUnselected : gear.name;
        final rides = store.selectedGearRides;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.gearRidesSection)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SelectedGearHeading(name: gearName),
              const SizedBox(height: 8),
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
                    if (!isManualRideId(ride.id)) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EditRideScreen(
                          store: store,
                          rideId: ride.id,
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
