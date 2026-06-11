import 'dart:math' show asin, cos, pi, sin, sqrt;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';
import '../../utils/l10n.dart';
import '../../widgets/shared_widgets.dart';

class TripCalculatorScreen extends StatefulWidget {
  const TripCalculatorScreen({super.key});

  @override
  State<TripCalculatorScreen> createState() => _TripCalculatorScreenState();
}

class _TripCalculatorScreenState extends State<TripCalculatorScreen> {
  // ── Map ──────────────────────────────────────────────────
  GoogleMapController? _mapCtrl;
  bool _mapError = false;

  // ── Locations ────────────────────────────────────────────
  LatLng? _pickupLatLng;
  LatLng? _destLatLng;
  String _pickupAddress = '';
  String _destAddress = '';
  bool _locating = false;
  bool _geocoding = false;

  // ── Fare rate controllers ─────────────────────────────────
  final _pricePerKmCtrl   = TextEditingController(text: '2.10');
  final _pricePerMinCtrl  = TextEditingController(text: '0.50');
  final _doorOpeningCtrl  = TextEditingController(text: '12.00');
  final _waitingRateCtrl  = TextEditingController(text: '0.50');
  final _tipCtrl          = TextEditingController(text: '0.00');
  final _parkingCtrl      = TextEditingController(text: '0.00');

  // ── Trip metric controllers ───────────────────────────────
  final _distCtrl         = TextEditingController(text: '0.0');
  final _durationCtrl     = TextEditingController(text: '0');
  final _waitMinsCtrl     = TextEditingController(text: '0');

  // ── Destination text field ────────────────────────────────
  final _destCtrl         = TextEditingController();

  // ── Optional toggles ─────────────────────────────────────
  bool _hasTip     = false;
  bool _hasParking = false;

  // ── Platform & result ────────────────────────────────────
  String _platform = 'Uber';
  double _estimatedFare = 0;
  bool _saving = false;

  // Fare breakdown
  double _distanceFare = 0;
  double _timeFare     = 0;
  double _waitingFare  = 0;

  final _platforms = ['Uber', 'Careem', 'Bolt', 'InDrive', 'Other'];

  @override
  void initState() {
    super.initState();
    _getLocation();
    for (final c in [
      _pricePerKmCtrl, _pricePerMinCtrl, _doorOpeningCtrl,
      _waitingRateCtrl, _tipCtrl, _parkingCtrl,
      _distCtrl, _durationCtrl, _waitMinsCtrl,
    ]) {
      c.addListener(_calculate);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _pricePerKmCtrl, _pricePerMinCtrl, _doorOpeningCtrl,
      _waitingRateCtrl, _tipCtrl, _parkingCtrl,
      _distCtrl, _durationCtrl, _waitMinsCtrl, _destCtrl,
    ]) {
      c.dispose();
    }
    _mapCtrl?.dispose();
    super.dispose();
  }

  // ── Get current GPS location ──────────────────────────────
  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final marks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = marks.first;
      final addr = [p.street, p.subLocality, p.locality]
          .where((s) => s != null && s.isNotEmpty)
          .join(', ');
      if (mounted) {
        setState(() {
          _pickupLatLng = LatLng(pos.latitude, pos.longitude);
          _pickupAddress = addr.isNotEmpty ? addr : 'Current Location';
        });
        _mapCtrl?.animateCamera(
          CameraUpdate.newLatLngZoom(_pickupLatLng!, 14),
        );
        _updateDistanceFromCoords();
      }
    } catch (_) {}
    if (mounted) setState(() => _locating = false);
  }

  // ── Geocode destination text → LatLng ────────────────────
  Future<void> _geocodeDest(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _geocoding = true);
    try {
      final locations = await geo.locationFromAddress(text);
      if (locations.isNotEmpty && mounted) {
        final loc = locations.first;
        setState(() {
          _destLatLng = LatLng(loc.latitude, loc.longitude);
          _destAddress = text;
        });
        _fitMapBounds();
        _updateDistanceFromCoords();
      }
    } catch (_) {}
    if (mounted) setState(() => _geocoding = false);
  }

  // ── Calculate straight-line distance (Haversine) ─────────
  void _updateDistanceFromCoords() {
    if (_pickupLatLng == null || _destLatLng == null) return;
    final km = _haversineKm(
      _pickupLatLng!.latitude, _pickupLatLng!.longitude,
      _destLatLng!.latitude,   _destLatLng!.longitude,
    );
    _distCtrl.text = km.toStringAsFixed(2);
    _calculate();
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * asin(sqrt(a));
  }

  double _toRad(double deg) => deg * pi / 180;

  // ── Fit map to show both markers ─────────────────────────
  void _fitMapBounds() {
    if (_mapCtrl == null || _pickupLatLng == null || _destLatLng == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _pickupLatLng!.latitude < _destLatLng!.latitude
            ? _pickupLatLng!.latitude : _destLatLng!.latitude,
        _pickupLatLng!.longitude < _destLatLng!.longitude
            ? _pickupLatLng!.longitude : _destLatLng!.longitude,
      ),
      northeast: LatLng(
        _pickupLatLng!.latitude > _destLatLng!.latitude
            ? _pickupLatLng!.latitude : _destLatLng!.latitude,
        _pickupLatLng!.longitude > _destLatLng!.longitude
            ? _pickupLatLng!.longitude : _destLatLng!.longitude,
      ),
    );
    _mapCtrl!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  // ── Fare calculation ──────────────────────────────────────
  void _calculate() {
    final km       = double.tryParse(_distCtrl.text)       ?? 0;
    final mins     = double.tryParse(_durationCtrl.text)    ?? 0;
    final waitMins = double.tryParse(_waitMinsCtrl.text)    ?? 0;
    final door     = double.tryParse(_doorOpeningCtrl.text) ?? 0;
    final perKm    = double.tryParse(_pricePerKmCtrl.text)  ?? 0;
    final perMin   = double.tryParse(_pricePerMinCtrl.text) ?? 0;
    final waitRate = double.tryParse(_waitingRateCtrl.text) ?? 0;
    final tip      = _hasTip    ? (double.tryParse(_tipCtrl.text)     ?? 0) : 0;
    final parking  = _hasParking ? (double.tryParse(_parkingCtrl.text) ?? 0) : 0;

    final dFare = km * perKm;
    final tFare = mins * perMin;
    final wFare = waitMins * waitRate;
    final total = door + dFare + tFare + wFare + tip + parking;

    setState(() {
      _distanceFare  = dFare;
      _timeFare      = tFare;
      _waitingFare   = wFare;
      _estimatedFare = total;
    });
  }

  // ── Save trip to Firestore ────────────────────────────────
  Future<void> _saveTrip() async {
    if (_estimatedFare <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in the fare details first'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (_pickupAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pickup location is required'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (_destAddress.isEmpty && _destCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Destination is required'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _saving = true);

    final uid      = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final currency = context.read<AppStateProvider>().currency;
    final now      = DateTime.now().toIso8601String();
    final destText = _destAddress.isNotEmpty ? _destAddress : _destCtrl.text;

    final trip = TripModel(
      id: '',
      pickupAddress:    _pickupAddress,
      pickupLat:        _pickupLatLng?.latitude  ?? 0,
      pickupLng:        _pickupLatLng?.longitude ?? 0,
      destinationAddress: destText,
      destinationLat:   _destLatLng?.latitude  ?? 0,
      destinationLng:   _destLatLng?.longitude ?? 0,
      distanceKm:       double.tryParse(_distCtrl.text)   ?? 0,
      durationMins:     int.tryParse(_durationCtrl.text)   ?? 0,
      waitingMins:      int.tryParse(_waitMinsCtrl.text)   ?? 0,
      pricePerKm:       double.tryParse(_pricePerKmCtrl.text)  ?? 0,
      pricePerMin:      double.tryParse(_pricePerMinCtrl.text) ?? 0,
      waitingRatePerMin: double.tryParse(_waitingRateCtrl.text) ?? 0,
      doorOpeningFee:   double.tryParse(_doorOpeningCtrl.text) ?? 0,
      tip:              _hasTip    ? (double.tryParse(_tipCtrl.text)     ?? 0) : 0,
      parkingFee:       _hasParking ? (double.tryParse(_parkingCtrl.text) ?? 0) : 0,
      distanceFare:     _distanceFare,
      timeFare:         _timeFare,
      waitingFare:      _waitingFare,
      fareAmount:       _estimatedFare,
      platform:         _platform,
      currency:         currency,
      dateTime:         now,
      status:           'completed',
      userId:           uid,
    );

    final saved = await context.read<TripProvider>().saveTrip(trip);
    setState(() => _saving = false);

    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Trip saved! ${_estimatedFare.toStringAsFixed(2)} $currency'),
        backgroundColor: AppColors.success,
      ));
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save. Check connection.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _resetForm() {
    _destCtrl.clear();
    _distCtrl.text    = '0.0';
    _durationCtrl.text = '0';
    _waitMinsCtrl.text = '0';
    _tipCtrl.text     = '0.00';
    _parkingCtrl.text = '0.00';
    setState(() {
      _destLatLng    = null;
      _destAddress   = '';
      _estimatedFare = 0;
      _hasTip        = false;
      _hasParking    = false;
    });
  }

  // ── Map widget ────────────────────────────────────────────
  Widget _buildMap() {
    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickupLatLng ?? const LatLng(24.7136, 46.6753),
          zoom: 13,
        ),
        onMapCreated: (c) {
          _mapCtrl = c;
          if (_pickupLatLng != null && _destLatLng != null) _fitMapBounds();
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        markers: {
          if (_pickupLatLng != null)
            Marker(
              markerId: const MarkerId('pickup'),
              position: _pickupLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: 'Pickup', snippet: _pickupAddress),
            ),
          if (_destLatLng != null)
            Marker(
              markerId: const MarkerId('dest'),
              position: _destLatLng!,
              infoWindow: InfoWindow(title: 'Destination', snippet: _destAddress),
            ),
        },
        polylines: (_pickupLatLng != null && _destLatLng != null)
            ? {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [_pickupLatLng!, _destLatLng!],
                  color: AppColors.primary,
                  width: 3,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
              }
            : {},
      );
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() => _mapError = true),
      );
      return _mapFallback();
    }
  }

  Widget _mapFallback() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: cs.secondary),
            const SizedBox(height: 8),
            Text('Map unavailable', style: Theme.of(context).textTheme.bodySmall),
            TextButton(
              onPressed: () => setState(() => _mapError = false),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l        = L10n(appState.language);
    final cs       = Theme.of(context).colorScheme;
    final currency = appState.currency;

    return Scaffold(
      body: Column(
        children: [
          // ── Map ────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                _mapError ? _mapFallback() : _buildMap(),
                // Lang toggle
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LangToggle(
                          current: appState.language,
                          onChanged: appState.setLanguage,
                        ),
                      ],
                    ),
                  ),
                ),
                // My-location button
                Positioned(
                  bottom: 10, right: 10,
                  child: FloatingActionButton.small(
                    heroTag: 'myLoc',
                    backgroundColor: cs.surface,
                    onPressed: _locating ? null : _getLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location_rounded,
                            color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // ── Form ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Location card ──────────────────────────
                  _locationCard(l, cs),
                  const SizedBox(height: 14),

                  // ── Section: Fare rates ────────────────────
                  _sectionLabel(context, l.isAr ? 'أسعار التعرفة' : 'Fare Rates'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: FareInputField(
                      label: l.pricePerKm, unit: currency,
                      controller: _pricePerKmCtrl)),
                    const SizedBox(width: 10),
                    Expanded(child: FareInputField(
                      label: l.pricePerMin, unit: currency,
                      controller: _pricePerMinCtrl)),
                    const SizedBox(width: 10),
                    Expanded(child: FareInputField(
                      label: l.baseFare, unit: currency,
                      controller: _doorOpeningCtrl)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: FareInputField(
                      label: l.waitingPerMin, unit: currency,
                      controller: _waitingRateCtrl)),
                    const SizedBox(width: 10),
                    // ── Tip (optional) ─────────────────────
                    Expanded(child: _optionalFareField(
                      label: l.tip,
                      unit: currency,
                      controller: _tipCtrl,
                      enabled: _hasTip,
                      onToggle: (v) => setState(() { _hasTip = v; _calculate(); }),
                    )),
                    const SizedBox(width: 10),
                    // ── Parking (optional) ─────────────────
                    Expanded(child: _optionalFareField(
                      label: l.isAr ? 'وقوف السيارات' : 'Parking',
                      unit: currency,
                      controller: _parkingCtrl,
                      enabled: _hasParking,
                      onToggle: (v) => setState(() { _hasParking = v; _calculate(); }),
                    )),
                  ]),

                  const SizedBox(height: 14),

                  // ── Section: Trip metrics ──────────────────
                  _sectionLabel(context, l.isAr ? 'بيانات الرحلة' : 'Trip Data'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: FareInputField(
                      label: l.distance, unit: l.km,
                      controller: _distCtrl)),
                    const SizedBox(width: 10),
                    Expanded(child: FareInputField(
                      label: l.isAr ? 'المدة (دقيقة)' : 'Duration (min)',
                      unit: 'min',
                      controller: _durationCtrl)),
                    const SizedBox(width: 10),
                    Expanded(child: FareInputField(
                      label: l.isAr ? 'انتظار (دقيقة)' : 'Wait (min)',
                      unit: 'min',
                      controller: _waitMinsCtrl)),
                  ]),

                  const SizedBox(height: 14),

                  // ── Platform dropdown ──────────────────────
                  _sectionLabel(context, l.platform),
                  const SizedBox(height: 6),
                  _platformDropdown(cs),

                  const SizedBox(height: 16),

                  // ── Fare breakdown card ────────────────────
                  if (_estimatedFare > 0) ...[
                    _fareBreakdownCard(l, currency, cs),
                    const SizedBox(height: 14),
                  ],

                  // ── Save button ────────────────────────────
                  PrimaryButton(
                    label: l.isAr ? 'حفظ الرحلة' : 'Save Trip',
                    loading: _saving,
                    onPressed: _saveTrip,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location card ─────────────────────────────────────────
  Widget _locationCard(L10n l, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Pickup row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pickupAddress.isEmpty ? l.currentLocation : _pickupAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_locating)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                else
                  GestureDetector(
                    onTap: _getLocation,
                    child: const Icon(Icons.my_location_rounded,
                      size: 18, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          // Dashed divider with swap icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Container(width: 1, height: 20, color: AppColors.divider),
              ],
            ),
          ),
          // Destination row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _destCtrl,
                    onSubmitted: (v) => _geocodeDest(v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l.destinationHint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_geocoding)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                else
                  GestureDetector(
                    onTap: () => _geocodeDest(_destCtrl.text),
                    child: const Icon(Icons.search_rounded,
                      size: 18, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          // Distance chip (auto-calculated)
          if (_pickupLatLng != null && _destLatLng != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route_outlined, size: 14,
                    color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${_distCtrl.text} km  •  '
                    '${(double.tryParse(_distCtrl.text) ?? 0) > 0 ? "auto-calculated" : ""}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Optional fare field with toggle ──────────────────────
  Widget _optionalFareField({
    required String label,
    required String unit,
    required TextEditingController controller,
    required bool enabled,
    required ValueChanged<bool> onToggle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
            ),
            GestureDetector(
              onTap: () => onToggle(!enabled),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28, height: 16,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 12, height: 12,
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context).textTheme.titleSmall,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(unit,
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: cs.secondary)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Fare breakdown card ───────────────────────────────────
  Widget _fareBreakdownCard(L10n l, String currency, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF5B7FF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.isAr ? 'تفصيل الأجرة' : 'Fare Breakdown',
            style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _fareRow(l.baseFare,
            '${(double.tryParse(_doorOpeningCtrl.text) ?? 0).toStringAsFixed(2)} $currency'),
          _fareRow(l.isAr ? 'أجرة المسافة (${_distCtrl.text} km)' : 'Distance (${_distCtrl.text} km)',
            '${_distanceFare.toStringAsFixed(2)} $currency'),
          if ((double.tryParse(_durationCtrl.text) ?? 0) > 0)
            _fareRow(l.isAr ? 'أجرة الوقت (${_durationCtrl.text} min)' : 'Time (${_durationCtrl.text} min)',
              '${_timeFare.toStringAsFixed(2)} $currency'),
          if ((double.tryParse(_waitMinsCtrl.text) ?? 0) > 0)
            _fareRow(l.isAr ? 'انتظار (${_waitMinsCtrl.text} min)' : 'Waiting (${_waitMinsCtrl.text} min)',
              '${_waitingFare.toStringAsFixed(2)} $currency'),
          if (_hasTip)
            _fareRow(l.tip,
              '${(double.tryParse(_tipCtrl.text) ?? 0).toStringAsFixed(2)} $currency'),
          if (_hasParking)
            _fareRow(l.isAr ? 'وقوف السيارات' : 'Parking',
              '${(double.tryParse(_parkingCtrl.text) ?? 0).toStringAsFixed(2)} $currency'),
          const Divider(color: Colors.white30, height: 20),
          Row(
            children: [
              Text(l.isAr ? 'الإجمالي' : 'Total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${_estimatedFare.toStringAsFixed(2)} $currency',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const Spacer(),
        Text(value,
          style: const TextStyle(color: Colors.white, fontSize: 12,
            fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _platformDropdown(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _platform,
          isExpanded: true,
          items: _platforms.map((p) => DropdownMenuItem(
            value: p, child: Text(p))).toList(),
          onChanged: (v) => setState(() => _platform = v ?? 'Uber'),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 0.8,
      color: AppColors.secondary,
    ),
  );
}
