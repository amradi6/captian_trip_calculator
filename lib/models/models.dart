import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;

  // ── Locations ────────────────────────────────────────────
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;

  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;

  // ── Trip metrics ─────────────────────────────────────────
  final double distanceKm;
  final int durationMins;
  final int waitingMins;

  // ── Fare rates (what the captain configured) ─────────────
  final double pricePerKm;
  final double pricePerMin;
  final double waitingRatePerMin;
  final double doorOpeningFee;   // base fare / door opening
  final double tip;              // optional
  final double parkingFee;       // optional

  // ── Fare totals (calculated) ──────────────────────────────
  final double distanceFare;
  final double timeFare;
  final double waitingFare;
  final double fareAmount;       // grand total

  // ── Meta ─────────────────────────────────────────────────
  final String platform;         // Uber / Careem / Bolt …
  final String currency;
  final String dateTime;
  final String status;           // completed | cancelled
  final String userId;

  TripModel({
    required this.id,
    required this.pickupAddress,
    this.pickupLat = 0,
    this.pickupLng = 0,
    required this.destinationAddress,
    this.destinationLat = 0,
    this.destinationLng = 0,
    required this.distanceKm,
    this.durationMins = 0,
    this.waitingMins = 0,
    this.pricePerKm = 0,
    this.pricePerMin = 0,
    this.waitingRatePerMin = 0,
    this.doorOpeningFee = 0,
    this.tip = 0,
    this.parkingFee = 0,
    this.distanceFare = 0,
    this.timeFare = 0,
    this.waitingFare = 0,
    required this.fareAmount,
    this.platform = 'Uber',
    this.currency = 'SAR',
    required this.dateTime,
    this.status = 'completed',
    required this.userId,
  });

  // ── Firestore → Model ────────────────────────────────────
  factory TripModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      pickupAddress: d['pickupAddress'] ?? '',
      pickupLat: (d['pickupLat'] ?? 0).toDouble(),
      pickupLng: (d['pickupLng'] ?? 0).toDouble(),
      destinationAddress: d['destinationAddress'] ?? '',
      destinationLat: (d['destinationLat'] ?? 0).toDouble(),
      destinationLng: (d['destinationLng'] ?? 0).toDouble(),
      distanceKm: (d['distanceKm'] ?? 0).toDouble(),
      durationMins: (d['durationMins'] ?? 0).toInt(),
      waitingMins: (d['waitingMins'] ?? 0).toInt(),
      pricePerKm: (d['pricePerKm'] ?? 0).toDouble(),
      pricePerMin: (d['pricePerMin'] ?? 0).toDouble(),
      waitingRatePerMin: (d['waitingRatePerMin'] ?? 0).toDouble(),
      doorOpeningFee: (d['doorOpeningFee'] ?? 0).toDouble(),
      tip: (d['tip'] ?? 0).toDouble(),
      parkingFee: (d['parkingFee'] ?? 0).toDouble(),
      distanceFare: (d['distanceFare'] ?? 0).toDouble(),
      timeFare: (d['timeFare'] ?? 0).toDouble(),
      waitingFare: (d['waitingFare'] ?? 0).toDouble(),
      fareAmount: (d['fareAmount'] ?? 0).toDouble(),
      platform: d['platform'] ?? 'Uber',
      currency: d['currency'] ?? 'SAR',
      dateTime: d['dateTime'] ?? '',
      status: d['status'] ?? 'completed',
      userId: d['userId'] ?? '',
    );
  }

  // ── Model → Firestore ────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'pickupAddress': pickupAddress,
    'pickupLat': pickupLat,
    'pickupLng': pickupLng,
    'destinationAddress': destinationAddress,
    'destinationLat': destinationLat,
    'destinationLng': destinationLng,
    'distanceKm': distanceKm,
    'durationMins': durationMins,
    'waitingMins': waitingMins,
    'pricePerKm': pricePerKm,
    'pricePerMin': pricePerMin,
    'waitingRatePerMin': waitingRatePerMin,
    'doorOpeningFee': doorOpeningFee,
    'tip': tip,
    'parkingFee': parkingFee,
    'distanceFare': distanceFare,
    'timeFare': timeFare,
    'waitingFare': waitingFare,
    'fareAmount': fareAmount,
    'platform': platform,
    'currency': currency,
    'dateTime': dateTime,
    'status': status,
    'userId': userId,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

// ── UserModel ─────────────────────────────────────────────
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;
  final double rating;
  final int totalTrips;
  final double totalKm;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.totalKm = 0,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: d['display_name'] ?? d['displayName'] ?? '',
      email: d['email'] ?? '',
      photoUrl: d['photo_url'],
      phoneNumber: d['phone_number'],
      rating: (d['rating'] ?? 5.0).toDouble(),
      totalTrips: (d['totalTrips'] ?? 0).toInt(),
      totalKm: (d['totalKm'] ?? 0).toDouble(),
    );
  }
}
