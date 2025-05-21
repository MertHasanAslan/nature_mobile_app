import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';

// FirebaseService provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

// User profile provider with better error handling
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;
  
  try {
    final firebaseService = ref.watch(firebaseServiceProvider);
    return await firebaseService.getProfile(user.uid);
  } catch (error, stackTrace) {
    throw AsyncError(error, stackTrace);
  }
});

// Profile management provider
final profileManagementProvider = StateNotifierProvider<ProfileManagementNotifier, AsyncValue<void>>((ref) {
  return ProfileManagementNotifier(ref.watch(firebaseServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  final _auth = FirebaseAuth.instance;

  void _init() {
    _auth.authStateChanges().listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Rethrow to handle in UI
    }
  }
}

class ProfileManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _firebaseService;

  ProfileManagementNotifier(this._firebaseService) : super(const AsyncValue.data(null));

  Future<void> createProfile(Profile profile) async {
    try {
      state = const AsyncValue.loading();
      await _firebaseService.createProfile(profile);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      state = const AsyncValue.loading();
      await _firebaseService.createProfile(profile); // createProfile metodu hem create hem update yapıyor
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
} 