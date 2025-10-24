import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video.dart';
import '../models/athlete.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Check if user was created successfully
      if (userCredential.user == null) {
        throw Exception('Failed to create user account');
      }

      // Update user profile with display name
      await userCredential.user!.updateDisplayName(fullName);

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user was signed in successfully
      if (userCredential.user == null) {
        throw Exception('Failed to sign in user');
      }

      // Update last login time
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLoginAt': FieldValue.serverTimestamp()},
      );

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Get user videos from Firestore
  Future<List<Video>> getUserVideos(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('videos')
              .where('coachId', isEqualTo: uid)
              .orderBy('uploadDate', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return Video.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user videos: $e');
    }
  }

  // Add new video
  Future<void> addVideo(Video video) async {
    try {
      await _firestore.collection('videos').add(video.toMap());
    } catch (e) {
      throw Exception('Failed to add video: $e');
    }
  }

  // Get user athletes from Firestore
  Future<List<Athlete>> getUserAthletes(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('athletes')
              .where('coachId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return Athlete.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user athletes: $e');
    }
  }

  // Add new athlete
  Future<void> addAthlete(Athlete athlete) async {
    try {
      // Validate that the user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Validate that the athlete belongs to the current user
      if (athlete.coachId != currentUser.uid) {
        throw Exception('Athlete coachId does not match current user');
      }

      final docRef = await _firestore
          .collection('athletes')
          .add(athlete.toMap());
      print('Athlete added successfully with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding athlete: $e');
      if (e.toString().contains('permission')) {
        throw Exception(
          'Permission denied. Please check your Firebase security rules.',
        );
      }
      throw Exception('Failed to add athlete: $e');
    }
  }

  // Update athlete
  Future<void> updateAthlete(Athlete athlete) async {
    try {
      await _firestore
          .collection('athletes')
          .doc(athlete.id)
          .update(athlete.toMap());
    } catch (e) {
      throw Exception('Failed to update athlete: $e');
    }
  }

  // Delete athlete
  Future<void> deleteAthlete(String athleteId) async {
    try {
      await _firestore.collection('athletes').doc(athleteId).delete();
    } catch (e) {
      throw Exception('Failed to delete athlete: $e');
    }
  }

  // Get athlete by ID
  Future<Athlete?> getAthleteById(String athleteId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('athletes').doc(athleteId).get();
      if (doc.exists) {
        return Athlete.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get athlete: $e');
    }
  }

  // Get videos for a specific athlete
  Future<List<Video>> getAthleteVideos(String athleteId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('videos')
              .where('athleteId', isEqualTo: athleteId)
              .orderBy('uploadDate', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return Video.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get athlete videos: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return 'Authentication failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
