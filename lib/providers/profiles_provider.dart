import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';
import 'package:cs_projesi/providers/auth_provider.dart';

final profilesProvider = StreamProvider<List<Profile>>((ref) {
  final firebaseService = FirebaseService();
  return firebaseService.getProfiles();
});

final profileProvider = FutureProvider.family<Profile?, String>((ref, profileId) async {
  final firebaseService = FirebaseService();
  return await firebaseService.getProfile(profileId);
});

final currentUserProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;
  
  final firebaseService = FirebaseService();
  return await firebaseService.getProfile(user.uid);
}); 