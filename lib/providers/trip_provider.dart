import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class TripProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TripModel> _trips = [];
  List<TripModel> get trips => _trips;

  bool _loading = false;
  bool get loading => _loading;

  String? get _uid => _auth.currentUser?.uid;

  // Earnings summaries
  double get todayEarnings {
    final today = DateTime.now();
    return _trips
      .where((t) => t.status == 'completed' && _isToday(t.dateTime, today))
      .fold(0.0, (s, t) => s + t.fareAmount);
  }

  double get monthEarnings {
    final now = DateTime.now();
    return _trips
      .where((t) => t.status == 'completed' && _isThisMonth(t.dateTime, now))
      .fold(0.0, (s, t) => s + t.fareAmount);
  }

  double get totalKm => _trips
    .where((t) => t.status == 'completed')
    .fold(0.0, (s, t) => s + t.distanceKm);

  int get completedTrips => _trips.where((t) => t.status == 'completed').length;

  List<double> get weeklyData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _trips
        .where((t) => t.status == 'completed' && _isSameDay(t.dateTime, day))
        .fold(0.0, (s, t) => s + t.fareAmount);
    });
  }

  Future<void> loadTrips() async {
    if (_uid == null) return;
    _loading = true;
    notifyListeners();
    try {
      final snap = await _db
        .collection('trips')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
      _trips = snap.docs.map(TripModel.fromDoc).toList();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<TripModel?> saveTrip(TripModel trip) async {
    if (_uid == null) return null;
    try {
      final ref = await _db.collection('trips').add(trip.toMap());
      final saved = TripModel(
        id: ref.id,
        pickupAddress: trip.pickupAddress,
        destinationAddress: trip.destinationAddress,
        distanceKm: trip.distanceKm,
        durationMins: trip.durationMins,
        waitingMins: trip.waitingMins,
        fareAmount: trip.fareAmount,
        baseFare: trip.baseFare,
        distanceFare: trip.distanceFare,
        timeFare: trip.timeFare,
        dateTime: trip.dateTime,
        status: trip.status,
        userId: trip.userId,
      );
      _trips.insert(0, saved);
      notifyListeners();
      return saved;
    } catch (_) {
      return null;
    }
  }

  TripModel? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  bool _isToday(String dt, DateTime today) {
    try {
      final d = DateTime.parse(dt);
      return d.year == today.year && d.month == today.month && d.day == today.day;
    } catch (_) {
      return false;
    }
  }

  bool _isThisMonth(String dt, DateTime now) {
    try {
      final d = DateTime.parse(dt);
      return d.year == now.year && d.month == now.month;
    } catch (_) {
      return false;
    }
  }

  bool _isSameDay(String dt, DateTime day) {
    try {
      final d = DateTime.parse(dt);
      return d.year == day.year && d.month == day.month && d.day == day.day;
    } catch (_) {
      return false;
    }
  }
}
