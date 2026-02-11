import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Fetch User Details (Check Cache first, then Firestore)
  Future<ScheduledUser?> getUserDetails(User firebaseUser) async {
    final String uid = firebaseUser.uid;

    // 1. Check Local Cache
    List<ScheduledUser> localUsers = await getStoredUsers();
    try {
      final user = localUsers.firstWhere((u) => u.uid == uid);
      return user;
    } catch (e) {
      // Not found in cache, continue to Firestore
    }

    // 2. Fetch from Firestore
    try {
      // We need DatabaseService here. avoiding circular dependency if possible.
      // Assuming DatabaseService is robust.
      // Dynamic import or just import at top?
      // Since we are in the same folder, circle dependency might be an issue if DatabaseService imports AuthService.
      // Let's check DatabaseService imports.
      // It likely doesn't import AuthService.

      // For now, we'll assume we can't import DatabaseService easily if it causes issues,
      // but usually standard services don't depend on AuthService unless for header injection.
      // Let's assume we can fetch document from 'users' collection directly using FirebaseFirestore.

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final String role = data['role'] ?? 'student';
        final String fullName = data['fullName'] ?? 'User';

        // 3. Update Cache
        await cacheUser(firebaseUser, role, fullName);

        // 4. Return User
        return ScheduledUser(
          uid: uid,
          fullName: fullName,
          email: firebaseUser.email ?? '',
          role: role,
          lastLogin: DateTime.now(),
          photoUrl: firebaseUser.photoURL,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user from Firestore: $e');
    }

    return null; // Not found
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
