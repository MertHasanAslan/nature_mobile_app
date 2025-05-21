import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';
import 'package:cs_projesi/providers/auth_provider.dart';

final eventsProvider = StreamProvider<List<Event>>((ref) {
  final firebaseService = FirebaseService();
  return firebaseService.getEvents();
});

final eventProvider = FutureProvider.family<Event?, String>((ref, eventId) async {
  final events = await ref.watch(eventsProvider.future);
  return events.firstWhere((event) => event.id == eventId);
});

final userEventsProvider = StreamProvider<List<Event>>((ref) {
  final firebaseService = FirebaseService();
  return firebaseService.getEvents().map((events) {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];
    return events.where((event) => event.createdBy == user.uid).toList();
  });
});

// NEW: Events by user id
final eventsByUserProvider = StreamProvider.family<List<Event>, String>((ref, userId) {
  final firebaseService = FirebaseService();
  return firebaseService.getEvents().map(
    (events) => events.where((event) => event.createdBy == userId).toList(),
  );
}); 