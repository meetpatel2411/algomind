import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduledUser {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String? photoUrl;
  final DateTime lastLogin;

  ScheduledUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.lastLogin,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory ScheduledUser.fromJson(Map<String, dynamic> json) {
    return ScheduledUser(
      uid: json['uid'],
      fullName: json['fullName'],
      email: json['email'],
      role: json['role'] ?? 'student',
      photoUrl: json['photoUrl'],
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _storageKey = 'routeminds_offline_users';
  static const String _defaultPin = '1234'; // MVP PIN

  // Login with Firebase & Cache Locallly
  Future<UserCredential> loginOnline(
    String email,
    String password,
    String role,
    String fullName,
  ) async {
    try {
      if (kDebugMode) print('Attempting online login for $email');
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cache User Locally on Success
      if (cred.user != null) {
        await cacheUser(cred.user!, role, fullName);
      }

      return cred;
    } catch (e) {
      if (kDebugMode) print('Online login failed: $e');
      rethrow;
    }
  }

  // Verify PIN for Offline Access
  Future<bool> verifyOfflinePin(String uid, String pin) async {
    // In real app, check hashed pin. For MVP/Demo:
    if (pin == _defaultPin) {
      return true;
    }
    return false;
  }

  // Get List of Saved Users
  Future<List<ScheduledUser>> getStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => ScheduledUser.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) print('Error parsing stored users: $e');
      return [];
    }
  }

  // Helper: Cache User
  Future<void> cacheUser(User user, String role, String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    List<ScheduledUser> users = await getStoredUsers();

    // Remove existing if any (update)
    users.removeWhere((u) => u.uid == user.uid);

    // Add updated
    users.add(
      ScheduledUser(
        uid: user.uid,
        fullName: fullName, // In real app, fetch from Firestore if not provided
        email: user.email!,
        role: role,
        lastLogin: DateTime.now(),
        photoUrl: user.photoURL,
      ),
    );

    // Save back
    String jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
    if (kDebugMode) print('User cached locally: ${user.uid}');
  }

  // Clear offline data (Logout from device)
  Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
