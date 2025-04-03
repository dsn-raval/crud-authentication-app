import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _role = "user";
  String get role => _role;

  User? _user;
  User? get user => _user;

  bool get isAuthenticated => _user != null;

  String? _profileImageUrl;
  String? get profileImageUrl => _profileImageUrl;

  AuthProvider() {
    _user = _auth.currentUser;
    _fetchUserProfile();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign In with Email & Password
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = _auth.currentUser;
      _fetchUserProfile();
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign up
  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user;

      await _firestore.collection("users").doc(_user!.uid).set({
        "uid": _user!.uid,
        "name": name,
        "email": _user!.email,
        "profileImageUrl":
            "https://wallpapers.com/images/high/cute-avatar-profile-picture-23yuqpb8wz1dqqqv.webp",
        "role": "user",
      });

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _role = "user";
    _profileImageUrl = null;
    notifyListeners();
  }

  Future<void> updateProfile(String name, XFile? imageFile) async {
    try {
      if (_user == null) return;

      String? imageUrl;
      if (imageFile != null) {
        File file = File(imageFile.path);
        TaskSnapshot snapshot = await _storage
            .ref('profile_pictures/${_user!.uid}')
            .putFile(file);

        imageUrl = await snapshot.ref.getDownloadURL();
        _profileImageUrl = imageUrl;
      }

      await _firestore.collection("users").doc(_user!.uid).update({
        "name": name,
        if (imageUrl != null) "profileImageUrl": imageUrl,
      });

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> _fetchUserProfile() async {
    if (_user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(_user!.uid).get();
    if (userDoc.exists) {
      _profileImageUrl = userDoc["profileImageUrl"];
      notifyListeners();
    }
  }

  // Google Sign-in
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      _user = userCredential.user;

      if (_user != null) {
        final userDoc =
            await _firestore.collection("users").doc(_user!.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection("users").doc(_user!.uid).set({
            "uid": _user!.uid,
            "name": _user!.displayName,
            "email": _user!.email,
            "role": "admin",
            "profileImageUrl":
                _user!.photoURL ??
                "https://wallpapers.com/images/high/cute-avatar-profile-picture-23yuqpb8wz1dqqqv.webp",
          });
        } else {
          _role = userDoc.get("role");
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Google Sign-In failed: $e");
    }
  }

  Future<void> fetchUserRole() async {
    if (_user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(_user!.uid).get();

    if (userDoc.exists) {
      _role = userDoc.get("role") ?? "user";
      notifyListeners();
    }
  }
}
