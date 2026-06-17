import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../utils/app_colors.dart';

class LocationPickerResult {
  final LatLng latLng;
  final String address;
  const LocationPickerResult({required this.latLng, required this.address});
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLatLng;
  final String title;
  final bool isAr;

  const LocationPickerScreen({
    super.key,
    this.initialLatLng,
    required this.title,
    this.isAr = false,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _ctrl;
  LatLng _center = const LatLng(24.7136, 46.6753);
  String _address = '';
  bool _geocoding = false;
  bool _locating = false;
  bool _moving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatLng != null) _center = widget.initialLatLng!;
    _reverseGeocode(_center);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _geocoding = true);
    try {
      final marks =
          await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        final parts = [p.street, p.subLocality, p.locality]
            .where((s) => s != null && s.isNotEmpty);
        setState(() {
          _address = parts.isNotEmpty
              ? parts.join(', ')
              : '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _address =
              '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
        });
      }
    }
    if (mounted) setState(() => _geocoding = false);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _ctrl?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    } catch (_) {}
    if (mounted) setState(() => _locating = false);
  }

  void _confirm() {
    Navigator.of(context)
        .pop(LocationPickerResult(latLng: _center, address: _address));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (c) => _ctrl = c,
            onCameraMove: (pos) {
              setState(() {
                _center = pos.target;
                _moving = true;
              });
            },
            onCameraIdle: () {
              setState(() => _moving = false);
              _reverseGeocode(_center);
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),

          // ── Fixed center pin ─────────────────────────────────
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                // Shift up so the pin tip sits at the exact center
                offset: const Offset(0, -32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: _moving ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.black87,
                          size: 28,
                        ),
                      ),
                    ),
                    // Pointer
                    CustomPaint(
                      size: const Size(14, 10),
                      painter: _TrianglePainter(),
                    ),
                    // Shadow dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: _moving ? 14 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar ──────────────────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                // Back button
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title chip
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom panel ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address row
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _geocoding
                            ? const SizedBox(
                                height: 16,
                                child: LinearProgressIndicator(
                                    minHeight: 2,
                                    backgroundColor: Colors.transparent))
                            : Text(
                                _address.isNotEmpty
                                    ? _address
                                    : (widget.isAr
                                        ? 'جارٍ التحديد...'
                                        : 'Locating...'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Button row
                  Row(
                    children: [
                      // My-location pill
                      GestureDetector(
                        onTap: _locating ? null : _goToMyLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _locating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.my_location_rounded,
                                      size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                widget.isAr
                                    ? 'موقعي الحالي'
                                    : 'My location',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Confirm button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_geocoding || _address.isEmpty)
                              ? null
                              : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.4),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.isAr ? 'تأكيد الموقع' : 'Confirm',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black26, 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter _) => false;
}
