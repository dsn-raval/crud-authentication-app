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
    _isLoading = true;
    notifyListeners();
    try {
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          _name = userDoc['name'] ?? "";
          _email = userDoc['email'] ?? user!.email ?? "";
          _photoUrl = userDoc['profileImageUrl'] ?? "";
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({required String name, File? image}) async {
    _isLoading = true;
    notifyListeners();
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
      notifyListeners();
    } catch (e) {
      print("Error updating profile: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
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
      print("Error uploading image: $e");
      return "";
    }
  }
}
