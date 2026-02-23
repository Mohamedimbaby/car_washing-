import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collection references
  static CollectionReference get users => firestore.collection('users');
  static CollectionReference get centers => firestore.collection('centers');
  static CollectionReference get bookings => firestore.collection('bookings');
  static CollectionReference get reviews => firestore.collection('reviews');
  static CollectionReference get staff => firestore.collection('staff');

  // Get current user ID
  static String? get currentUserId => auth.currentUser?.uid;

  // Check if user is logged in
  static bool get isLoggedIn => auth.currentUser != null;
}
