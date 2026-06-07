import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final double distanceKm;
  final int durationMins;
  final int waitingMins;
  final double fareAmount;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final String dateTime;
  final String status; // completed | cancelled
  final String userId;

  TripModel({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.distanceKm,
    required this.durationMins,
    required this.waitingMins,
    required this.fareAmount,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.dateTime,
    required this.status,
    required this.userId,
  });

  factory TripModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      pickupAddress: d['pickupAddress'] ?? '',
      destinationAddress: d['destinationAddress'] ?? '',
      distanceKm: (d['distanceKm'] ?? 0).toDouble(),
      durationMins: (d['durationMins'] ?? 0).toInt(),
      waitingMins: (d['waitingMins'] ?? 0).toInt(),
      fareAmount: (d['fareAmount'] ?? 0).toDouble(),
      baseFare: (d['baseFare'] ?? 0).toDouble(),
      distanceFare: (d['distanceFare'] ?? 0).toDouble(),
      timeFare: (d['timeFare'] ?? 0).toDouble(),
      dateTime: d['dateTime'] ?? '',
      status: d['status'] ?? 'completed',
      userId: d['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'pickupAddress': pickupAddress,
    'destinationAddress': destinationAddress,
    'distanceKm': distanceKm,
    'durationMins': durationMins,
    'waitingMins': waitingMins,
    'fareAmount': fareAmount,
    'baseFare': baseFare,
    'distanceFare': distanceFare,
    'timeFare': timeFare,
    'dateTime': dateTime,
    'status': status,
    'userId': userId,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

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

class EarningsModel {
  final double dailyTotal;
  final double weeklyTotal;
  final double monthlyTotal;
  final String currencyCode;

  EarningsModel({
    this.dailyTotal = 0,
    this.weeklyTotal = 0,
    this.monthlyTotal = 0,
    this.currencyCode = 'SAR',
  });

  factory EarningsModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EarningsModel(
      dailyTotal: (d['dailyTotal'] ?? 0).toDouble(),
      weeklyTotal: (d['weeklyTotal'] ?? 0).toDouble(),
      monthlyTotal: (d['monthlyTotal'] ?? 0).toDouble(),
      currencyCode: d['currencyCode'] ?? 'SAR',
    );
  }
}
