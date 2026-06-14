import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // serverClientId = the web OAuth client (type 3) from google-services.json
  // This is required for Google Sign-In to work on Android
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '621029142110-n2u7lfug37n97o1ppn1thrnibi2t2c2g.apps.googleusercontent.com',
  );

  User? get firebaseUser => _auth.currentUser;
  bool get isLoggedIn => firebaseUser != null;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) _loadUserModel(user.uid);
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromDoc(doc);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authMessage(e.code);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createAccount(String name, String email, String password, String phone) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);
      await _db.collection('users').doc(cred.user!.uid).set({
        'display_name': name,
        'email': email,
        'phone_number': phone,
        'uid': cred.user!.uid,
        'created_time': FieldValue.serverTimestamp(),
        'rating': 5.0,
        'totalTrips': 0,
        'totalKm': 0.0,
      });
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authMessage(e.code);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      // create user doc if new
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(cred.user!.uid).set({
          'display_name': cred.user!.displayName ?? '',
          'email': cred.user!.email ?? '',
          'photo_url': cred.user!.photoURL,
          'uid': cred.user!.uid,
          'created_time': FieldValue.serverTimestamp(),
          'rating': 5.0,
          'totalTrips': 0,
          'totalKm': 0.0,
        });
      }
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authMessage(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().contains('network')
          ? 'Network error. Check your connection.'
          : 'Google Sign-In failed. Try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authMessage(e.code);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  String _authMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-credential': return 'Incorrect email or password.';
      case 'email-already-in-use': return 'Email already in use.';
      case 'weak-password': return 'Password is too weak.';
      case 'invalid-email': return 'Invalid email address.';
      case 'too-many-requests': return 'Too many attempts. Try later.';
      default: return 'An error occurred. Please try again.';
    }
  }
}
