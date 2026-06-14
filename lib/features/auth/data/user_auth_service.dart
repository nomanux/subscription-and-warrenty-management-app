/// Traditional username/password authentication service.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserAuthService {
  UserAuthService._();

  static final UserAuthService instance = UserAuthService._();

  final _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _currentUsername;

  /// Get current logged-in user ID.
  String? get currentUserId => _currentUserId;

  /// Get current logged-in username.
  String? get currentUsername => _currentUsername;

  /// Check if user is logged in.
  bool get isLoggedIn => _currentUserId != null;

  /// Login with username and password.
  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw StateError('Username and password are required.');
    }

    try {
      // Hash password (simple approach - in production, use proper hashing)
      final hashedPassword = _hashPassword(password);

      // Query for user in Firestore
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: hashedPassword)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw StateError('Invalid username or password.');
      }

      final userDoc = query.docs.first;
      _currentUserId = userDoc.id;
      _currentUsername = userDoc['username'] as String;

      debugPrint('User logged in: $_currentUsername');
    } catch (e) {
      _currentUserId = null;
      _currentUsername = null;
      rethrow;
    }
  }

  /// Register a new user with username and password.
  Future<void> signup(
    String username,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      throw StateError('All fields are required.');
    }

    if (password != passwordConfirm) {
      throw StateError('Passwords do not match.');
    }

    if (password.length < 6) {
      throw StateError('Password must be at least 6 characters.');
    }

    try {
      // Check if username already exists
      final existing = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw StateError('Username already exists.');
      }

      final hashedPassword = _hashPassword(password);

      // Create user in Firestore
      final userRef = await _firestore.collection('users').add({
        'username': username,
        'email': email,
        'password': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUserId = userRef.id;
      _currentUsername = username;

      debugPrint('User registered: $username');
    } catch (e) {
      rethrow;
    }
  }

  /// Logout current user.
  Future<void> logout() async {
    _currentUserId = null;
    _currentUsername = null;
    debugPrint('User logged out');
  }

  /// Simple password hash (DO NOT USE IN PRODUCTION).
  /// For production, use bcrypt or similar.
  String _hashPassword(String password) {
    // This is a simple XOR hash for demo purposes only
    int hash = 5381;
    for (int i = 0; i < password.length; i++) {
      hash = ((hash << 5) + hash) ^ password.codeUnitAt(i);
    }
    return hash.toString();
  }
}
