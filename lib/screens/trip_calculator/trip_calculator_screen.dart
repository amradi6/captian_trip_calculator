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

// Use legacy renderer on Android to avoid emulator crashes with Vulkan
// ignore: avoid_classes_with_only_static_members

class TripCalculatorScreen extends StatefulWidget {
  const TripCalculatorScreen({super.key});

  @override
  State<TripCalculatorScreen> createState() => _TripCalculatorScreenState();
}

class _TripCalculatorScreenState extends State<TripCalculatorScreen> {
  GoogleMapController? _mapCtrl;
  LatLng? _currentPos;
  LatLng? _destPos;
  String _pickupText = '';
  bool _mapError = false;

  final _destCtrl = TextEditingController();
  final _pricePerKmCtrl = TextEditingController(text: '2.10');
  final _pricePerMinCtrl = TextEditingController(text: '0.50');
  final _baseFareCtrl = TextEditingController(text: '12.00');
  final _waitingCtrl = TextEditingController(text: '0.50');
  final _tipCtrl = TextEditingController(text: '0.00');
  final _distCtrl = TextEditingController(text: '0.0');
  final _durationCtrl = TextEditingController(text: '0');
  final _waitMinsCtrl = TextEditingController(text: '0');
  final _workDaysCtrl = TextEditingController(text: '1');

  String _platform = 'Uber';
  double _estimatedFare = 0;
  bool _saving = false;

  final _platforms = ['Uber', 'Careem', 'Bolt', 'InDrive', 'Other'];

  @override
  void initState() {
    super.initState();
    _getLocation();
    for (final c in [
      _pricePerKmCtrl, _pricePerMinCtrl, _baseFareCtrl,
      _waitingCtrl, _tipCtrl, _distCtrl, _durationCtrl, _waitMinsCtrl,
    ]) {
      c.addListener(_calculate);
    }
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    for (final c in [
      _pricePerKmCtrl, _pricePerMinCtrl, _baseFareCtrl,
      _waitingCtrl, _tipCtrl, _distCtrl, _durationCtrl, _waitMinsCtrl, _workDaysCtrl,
    ]) {
      c.dispose();
    }
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      final placemarks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.first;
      if (mounted) {
        setState(() {
          _currentPos = LatLng(pos.latitude, pos.longitude);
          _pickupText = '${p.street ?? ''}, ${p.locality ?? ''}';
        });
      }
    } catch (_) {}
  }

  void _calculate() {
    final km = double.tryParse(_distCtrl.text) ?? 0;
    final mins = double.tryParse(_durationCtrl.text) ?? 0;
    final waitMins = double.tryParse(_waitMinsCtrl.text) ?? 0;
    final base = double.tryParse(_baseFareCtrl.text) ?? 0;
    final perKm = double.tryParse(_pricePerKmCtrl.text) ?? 0;
    final perMin = double.tryParse(_pricePerMinCtrl.text) ?? 0;
    final waitRate = double.tryParse(_waitingCtrl.text) ?? 0;
    final tip = double.tryParse(_tipCtrl.text) ?? 0;

    final fare = base + (km * perKm) + (mins * perMin) + (waitMins * waitRate) + tip;
    setState(() => _estimatedFare = fare);
  }

  Future<void> _saveTrip() async {
    if (_estimatedFare <= 0) return;
    setState(() => _saving = true);

    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final now = DateTime.now().toIso8601String();
    final trip = TripModel(
      id: '',
      pickupAddress: _pickupText.isEmpty ? 'Current Location' : _pickupText,
      destinationAddress: _destCtrl.text.isEmpty ? 'Destination' : _destCtrl.text,
      distanceKm: double.tryParse(_distCtrl.text) ?? 0,
      durationMins: int.tryParse(_durationCtrl.text) ?? 0,
      waitingMins: int.tryParse(_waitMinsCtrl.text) ?? 0,
      fareAmount: _estimatedFare,
      baseFare: double.tryParse(_baseFareCtrl.text) ?? 0,
      distanceFare: (double.tryParse(_distCtrl.text) ?? 0) *
          (double.tryParse(_pricePerKmCtrl.text) ?? 0),
      timeFare: (double.tryParse(_durationCtrl.text) ?? 0) *
          (double.tryParse(_pricePerMinCtrl.text) ?? 0),
      dateTime: now,
      status: 'completed',
      userId: uid,
    );

    final saved = await context.read<TripProvider>().saveTrip(trip);
    setState(() => _saving = false);

    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildMap() {
    return Builder(builder: (context) {
      try {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPos ?? const LatLng(24.7136, 46.6753),
            zoom: 13,
          ),
          onMapCreated: (c) => _mapCtrl = c,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: {
            if (_currentPos != null)
              Marker(
                markerId: const MarkerId('pickup'),
                position: _currentPos!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
              ),
            if (_destPos != null)
              Marker(
                markerId: const MarkerId('dest'),
                position: _destPos!,
              ),
          },
        );
      } catch (_) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _mapError = true),
        );
        return _mapFallback(context);
      }
    });
  }

  Widget _mapFallback(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: cs.secondary),
            const SizedBox(height: 8),
            Text('Map unavailable on this device',
              style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => setState(() => _mapError = false),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l = L10n(appState.language);
    final cs = Theme.of(context).colorScheme;
    final currency = appState.currency;

    return Scaffold(
      body: Column(
        children: [
          // Map
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                _mapError ? _mapFallback(context) : _buildMap(),
                // Safe area top
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                // Location button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    backgroundColor: cs.surface,
                    onPressed: _getLocation,
                    child: const Icon(Icons.my_location_rounded,
                      color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _pickupText.isEmpty ? l.currentLocation : _pickupText,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const Icon(Icons.my_location_rounded,
                                size: 18, color: AppColors.secondary),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                size: 18, color: AppColors.error),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _destCtrl,
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
                              const Icon(Icons.location_searching_rounded,
                                size: 18, color: AppColors.secondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Fare inputs grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: [
                      FareInputField(label: l.pricePerKm, unit: currency, controller: _pricePerKmCtrl),
                      FareInputField(label: l.pricePerMin, unit: currency, controller: _pricePerMinCtrl),
                      FareInputField(label: l.baseFare, unit: currency, controller: _baseFareCtrl),
                      FareInputField(label: l.waitingPerMin, unit: currency, controller: _waitingCtrl),
                      FareInputField(label: l.tip, unit: currency, controller: _tipCtrl),
                      FareInputField(label: l.distance, unit: l.km, controller: _distCtrl),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Duration & Wait inputs
                  Row(
                    children: [
                      Expanded(
                        child: FareInputField(
                          label: 'Duration (min)',
                          unit: 'min',
                          controller: _durationCtrl,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FareInputField(
                          label: 'Wait (min)',
                          unit: 'min',
                          controller: _waitMinsCtrl,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FareInputField(
                          label: l.workingDays,
                          unit: '',
                          controller: _workDaysCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Platform
                  Text(l.platform, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Container(
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
                          value: p,
                          child: Text(p),
                        )).toList(),
                        onChanged: (v) => setState(() => _platform = v ?? 'Uber'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Estimated earnings
                  if (_estimatedFare > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF5B7FF5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.estimatedEarnings,
                                style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                              Text(
                                '${_estimatedFare.toStringAsFixed(2)} $currency',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '× ${_workDaysCtrl.text} = '
                            '${(_estimatedFare * (double.tryParse(_workDaysCtrl.text) ?? 1)).toStringAsFixed(2)} $currency',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l.calculate,
                    loading: _saving,
                    onPressed: _saveTrip,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
