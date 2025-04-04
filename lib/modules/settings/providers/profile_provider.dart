import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileProvider extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  User? get user => _auth.currentUser;

  String _name = "";
  String _email = "";
  String _photoUrl = "";
  String _uid = "";
  String _role = "";
  bool _isLoading = false;

  String get name => _name;
  String get email => _email;
  String get photoUrl => _photoUrl;
  String get uid => _uid;
  String get role => _role;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    fetchUserProfile();
  }

  // Fetch user profile from Firestore
  Future<void> fetchUserProfile() async {
    _setLoading(true);
    if (user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _name = data['name'] ?? '';
        _email = data['email'] ?? user!.email ?? '';
        _photoUrl = data['profileImageUrl'] ?? '';
        _uid = user!.uid;
      }
    } catch (e) {
      debugPrint("❌ Error fetching profile: $e");
    }
    _setLoading(false);
  }

  // Update user profile
  Future<void> updateProfile({required String name, File? image}) async {
    if (user == null) return;

    _setLoading(true);
    try {
      String imageUrl = _photoUrl;
      if (image != null) {
        imageUrl = await _uploadImage(image);
      }

      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': user!.email,
        'profileImageUrl': imageUrl,
      }, SetOptions(merge: true));

      _name = name;
      _photoUrl = imageUrl;
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
    }
    _isLoading = false;
    _setLoading(false);
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      return picked != null ? File(picked.path) : null;
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
      return null;
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      Reference storageRef = _storage.ref().child(
        "profile_pictures/${user!.uid}.jpg",
      );
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Error uploading image: $e");
      return "";
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
