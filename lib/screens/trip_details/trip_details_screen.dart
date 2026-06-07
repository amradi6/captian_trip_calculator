import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';

class TripDetailsScreen extends StatelessWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l = L10n(appState.language);
    final trip = context.read<TripProvider>().getTripById(tripId);
    final cs = Theme.of(context).colorScheme;
    final currency = appState.currency;

    return Scaffold(
      body: trip == null
        ? Center(child: Text(l.noTrips))
        : Column(
          children: [
            // Map
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(24.7136, 46.6753),
                      zoom: 12,
                    ),
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cs.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              'Trip #${tripId.substring(0, 6).toUpperCase()}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route
                    _routeRow(context,
                      Icons.circle, AppColors.primary, trip.pickupAddress, 'Pickup'),
                    const SizedBox(height: 6),
                    _routeRow(context,
                      Icons.location_on, AppColors.error, trip.destinationAddress, 'Destination'),
                    const SizedBox(height: 20),
                    // Stats
                    Row(
                      children: [
                        Expanded(child: _statBox(context,
                          Icons.route_outlined, '${trip.distanceKm.toStringAsFixed(1)} km',
                          l.distance)),
                        const SizedBox(width: 12),
                        Expanded(child: _statBox(context,
                          Icons.access_time_outlined, '${trip.durationMins} ${l.mins}',
                          l.duration)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _statBox(context,
                          Icons.person_outline, '${trip.waitingMins} ${l.mins}',
                          l.waiting)),
                        const SizedBox(width: 12),
                        Expanded(child: _statBox(context,
                          Icons.star_rounded, '5.0 ★',
                          l.rating)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Fare breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _fareRow(context, 'Base Fare',
                            '${trip.baseFare.toStringAsFixed(2)} $currency'),
                          const SizedBox(height: 8),
                          _fareRow(context, 'Distance Fare',
                            '${trip.distanceFare.toStringAsFixed(2)} $currency'),
                          const SizedBox(height: 8),
                          _fareRow(context, 'Time Fare',
                            '${trip.timeFare.toStringAsFixed(2)} $currency'),
                          const Divider(height: 20),
                          _fareRow(context, l.fare,
                            '${trip.fareAmount.toStringAsFixed(2)} $currency',
                            bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _routeRow(BuildContext context, IconData icon, Color color,
      String address, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: Theme.of(context).textTheme.bodySmall),
              Text(address,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(BuildContext context, IconData icon, String value, String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareRow(BuildContext context, String label, String value,
      {bool bold = false}) {
    final style = bold
      ? Theme.of(context).textTheme.titleSmall
      : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value,
          style: style?.copyWith(
            color: bold ? AppColors.primary : null,
          )),
      ],
    );
  }
}
