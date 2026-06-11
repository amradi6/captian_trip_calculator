import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/models.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _mapError = false;

  Widget _buildMap(TripModel trip) {
    final hasPickup = trip.pickupLat != 0 || trip.pickupLng != 0;
    final hasDest   = trip.destinationLat != 0 || trip.destinationLng != 0;
    final pickup    = LatLng(trip.pickupLat, trip.pickupLng);
    final dest      = LatLng(trip.destinationLat, trip.destinationLng);

    LatLng center = hasPickup ? pickup : const LatLng(24.7136, 46.6753);

    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 12),
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onMapCreated: (ctrl) {
          if (hasPickup && hasDest) {
            final bounds = LatLngBounds(
              southwest: LatLng(
                pickup.latitude < dest.latitude ? pickup.latitude : dest.latitude,
                pickup.longitude < dest.longitude ? pickup.longitude : dest.longitude,
              ),
              northeast: LatLng(
                pickup.latitude > dest.latitude ? pickup.latitude : dest.latitude,
                pickup.longitude > dest.longitude ? pickup.longitude : dest.longitude,
              ),
            );
            ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
          }
        },
        markers: {
          if (hasPickup)
            Marker(
              markerId: const MarkerId('pickup'),
              position: pickup,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: 'Pickup', snippet: trip.pickupAddress),
            ),
          if (hasDest)
            Marker(
              markerId: const MarkerId('dest'),
              position: dest,
              infoWindow: InfoWindow(title: 'Destination', snippet: trip.destinationAddress),
            ),
        },
        polylines: (hasPickup && hasDest)
            ? {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [pickup, dest],
                  color: AppColors.primary,
                  width: 3,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
              }
            : {},
      );
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _mapError = true));
      return _mapFallback();
    }
  }

  Widget _mapFallback() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.map_outlined, size: 48, color: cs.secondary),
          const SizedBox(height: 8),
          Text('Map unavailable',
              style: Theme.of(context).textTheme.bodySmall),
          TextButton(
            onPressed: () => setState(() => _mapError = false),
            child: const Text('Retry'),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l        = L10n(appState.language);
    final trip     = context.read<TripProvider>().getTripById(widget.tripId);
    final cs       = Theme.of(context).colorScheme;
    final currency = appState.currency;
    final isAr     = appState.language == 'ar';

    if (trip == null) {
      return Scaffold(body: Center(child: Text(l.noTrips)));
    }

    return Scaffold(
      body: Column(
        children: [
          // ── Map ──────────────────────────────────────────────
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                _mapError ? _mapFallback() : _buildMap(trip),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: cs.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          ),
                        ),
                        const Spacer(),
                        // Platform badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Text(
                            '${trip.platform}  •  #${widget.tripId.substring(0, 6).toUpperCase()}',
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

          // ── Details ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Route ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _routeRow(context,
                            Icons.circle, AppColors.primary,
                            isAr ? 'نقطة الانطلاق' : 'Pickup',
                            trip.pickupAddress),
                        const Padding(
                          padding: EdgeInsets.only(left: 7),
                          child: SizedBox(
                            width: 1, height: 20,
                            // ignore: unused_child
                          ),
                        ),
                        _routeRow(context,
                            Icons.location_on, AppColors.error,
                            isAr ? 'الوجهة' : 'Destination',
                            trip.destinationAddress),
                        // Coordinates row
                        if (trip.pickupLat != 0) ...[
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.explore_outlined, size: 13,
                                  color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                '${trip.pickupLat.toStringAsFixed(4)}, ${trip.pickupLng.toStringAsFixed(4)}'
                                '  →  '
                                '${trip.destinationLat.toStringAsFixed(4)}, ${trip.destinationLng.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Trip metrics ───────────────────────────────
                  Row(children: [
                    Expanded(child: _statBox(context,
                        Icons.route_outlined,
                        '${trip.distanceKm.toStringAsFixed(2)} km',
                        isAr ? 'المسافة' : 'Distance')),
                    const SizedBox(width: 10),
                    Expanded(child: _statBox(context,
                        Icons.access_time_outlined,
                        '${trip.durationMins} min',
                        isAr ? 'المدة' : 'Duration')),
                    const SizedBox(width: 10),
                    Expanded(child: _statBox(context,
                        Icons.hourglass_bottom_rounded,
                        '${trip.waitingMins} min',
                        isAr ? 'الانتظار' : 'Waiting')),
                  ]),

                  const SizedBox(height: 14),

                  // ── Fare breakdown ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isAr ? 'تفصيل الأجرة' : 'Fare Breakdown',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        _fareRow(context,
                            isAr ? 'فتح الباب / الأجرة الأساسية' : 'Door Opening / Base',
                            trip.doorOpeningFee, currency),
                        _fareRow(context,
                            isAr ? 'أجرة المسافة' : 'Distance Fare',
                            trip.distanceFare, currency),
                        if (trip.timeFare > 0)
                          _fareRow(context,
                              isAr ? 'أجرة الوقت' : 'Time Fare',
                              trip.timeFare, currency),
                        if (trip.waitingFare > 0)
                          _fareRow(context,
                              isAr ? 'أجرة الانتظار' : 'Waiting Fare',
                              trip.waitingFare, currency),
                        if (trip.tip > 0)
                          _fareRow(context,
                              isAr ? 'إكرامية' : 'Tip',
                              trip.tip, currency,
                              color: AppColors.success),
                        if (trip.parkingFee > 0)
                          _fareRow(context,
                              isAr ? 'وقوف السيارات' : 'Parking',
                              trip.parkingFee, currency),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Text(isAr ? 'الإجمالي' : 'Total',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text(
                              '${trip.fareAmount.toStringAsFixed(2)} $currency',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Rates used ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isAr ? 'معدلات التعرفة المستخدمة' : 'Rates Used',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 0.8, color: AppColors.secondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 6,
                          children: [
                            _rateChip(context,
                                '${trip.pricePerKm.toStringAsFixed(2)} / km'),
                            _rateChip(context,
                                '${trip.pricePerMin.toStringAsFixed(2)} / min'),
                            _rateChip(context,
                                '${trip.waitingRatePerMin.toStringAsFixed(2)} wait/min'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Date / Status ──────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _statBox(context,
                          Icons.calendar_today_outlined,
                          _formatDate(trip.dateTime),
                          isAr ? 'التاريخ' : 'Date')),
                      const SizedBox(width: 10),
                      Expanded(child: _statBox(context,
                          Icons.check_circle_outline_rounded,
                          trip.status,
                          isAr ? 'الحالة' : 'Status',
                          valueColor: trip.status == 'completed'
                              ? AppColors.success : AppColors.error)),
                    ],
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
      String label, String address) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(address,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(BuildContext context, IconData icon, String value,
      String label, {Color? valueColor}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: valueColor,
                        ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareRow(BuildContext context, String label, double amount,
      String currency, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _rateChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
