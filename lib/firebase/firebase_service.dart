import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Profile Operations
  Future<void> createProfile(Profile profile) async {
    await _firestore.collection('profiles').doc(profile.id).set({
      'id': profile.id,
      'name': profile.name,
      'surname': profile.surname,
      'hasEvent': profile.hasEvent,
      'profilePhotoPath': profile.profilePhotoPath,
      'createdBy': profile.createdBy,
      'createdAt': profile.createdAt,
      'age': profile.age,
      'bio': profile.bio,
      'favoriteActivities': profile.favoriteActivities,
      'favoritePlaces': profile.favoritePlaces,
    });
  }

  Future<Profile?> getProfile(String id) async {
    DocumentSnapshot doc = await _firestore.collection('profiles').doc(id).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Profile(
        id: data['id'],
        name: data['name'],
        surname: data['surname'],
        hasEvent: data['hasEvent'],
        profilePhotoPath: data['profilePhotoPath'],
        createdBy: data['createdBy'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        age: data['age'] ?? 0,
        bio: data['bio'] ?? '',
        favoriteActivities: List<String>.from(data['favoriteActivities'] ?? []),
        favoritePlaces: List<String>.from(data['favoritePlaces'] ?? []),
      );
    }
    return null;
  }

  Stream<List<Profile>> getProfiles() {
    return _firestore.collection('profiles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Profile(
          id: data['id'],
          name: data['name'],
          surname: data['surname'],
          hasEvent: data['hasEvent'],
          profilePhotoPath: data['profilePhotoPath'],
          createdBy: data['createdBy'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          age: data['age'] ?? 0,
          bio: data['bio'] ?? '',
          favoriteActivities: List<String>.from(data['favoriteActivities'] ?? []),
          favoritePlaces: List<String>.from(data['favoritePlaces'] ?? []),
        );
      }).toList();
    });
  }

  // Event Operations
  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).set({
      'id': event.id,
      'createdBy': event.createdBy,
      'location': event.location,
      'coordinates': GeoPoint(event.coordinates.latitude, event.coordinates.longitude),
      'date': event.date,
      'descriptionMini': event.descriptionMini,
      'eventPhotoPath': event.eventPhotoPath,
      'descriptionLarge': event.descriptionLarge,
      'where': event.where,
      'bring': event.bring,
      'goal': event.goal,
      'when': event.when,
      'createdAt': event.createdAt,
    });
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      List<Event> events = [];
      for (final doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data();
          // Flexible coordinates parsing - prioritize GeoPoint
          LatLng coordinates;
          final coord = data['coordinates'];
          if (coord is GeoPoint) {
            coordinates = LatLng(coord.latitude, coord.longitude);
          } else if (coord is List && coord.length == 2) {
            coordinates = LatLng(coord[0], coord[1]);
          } else if (coord is Map && coord.containsKey('_latitude') && coord.containsKey('_longitude')) {
            coordinates = LatLng(coord['_latitude'], coord['_longitude']);
          } else {
            print('Event ${data['id'] ?? 'unknown'} skipped: invalid coordinates format');
            continue;
          }
          // Check for required fields
          final requiredFields = [
            'id', 'createdBy', 'location', 'date', 'descriptionMini',
            'eventPhotoPath', 'descriptionLarge', 'where', 'bring', 'goal', 'when', 'createdAt',
          ];
          bool hasNull = false;
          for (final field in requiredFields) {
            if (!data.containsKey(field) || data[field] == null) {
              print('Event ${data['id'] ?? 'unknown'} skipped: missing $field');
              hasNull = true;
              break;
            }
          }
          if (hasNull) continue;
          events.add(Event(
            id: data['id'],
            createdBy: data['createdBy'],
            location: data['location'],
            coordinates: coordinates,
            date: (data['date'] is Timestamp)
                ? (data['date'] as Timestamp).toDate()
                : DateTime.tryParse(data['date'].toString()) ?? DateTime.now(),
            descriptionMini: data['descriptionMini'],
            eventPhotoPath: data['eventPhotoPath'],
            descriptionLarge: data['descriptionLarge'],
            where: data['where'],
            bring: data['bring'],
            goal: data['goal'],
            when: data['when'],
            createdAt: (data['createdAt'] is Timestamp)
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now(),
          ));
        } catch (e) {
          print('Error parsing event: $e');
          continue;
        }
      }
      return events;
    });
  }

  // Image Upload
  Future<String> uploadImage(File imageFile, String path) async {
    Reference ref = _storage.ref().child(path);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('profiles').doc(userId).update(data);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /*
  // Upload Dummy Data - Artık kullanılmıyor
  Future<void> uploadDummyData() async {
    // Create dummy profiles
    final List<Profile> dummyProfiles = [
      Profile(
        id: '1',
        name: "Demir",
        surname: "Demir",
        hasEvent: true,
        profilePhotoPath: "assets/profile_photos/demir.jpg",
        createdBy: 'system',
        createdAt: DateTime.now(),
        age: 28,
        bio: "Hi, I'm Demir—a passionate hiker and nature lover. I enjoy exploring new trails and organizing group hikes in the forests around Istanbul.",
        favoriteActivities: ["Hiking", "Organizing group hikes"],
        favoritePlaces: ["Belgrad Forest", "Polonezköy Nature Park"],
      ),
      // ... diğer dummy profiller
    ];

    // Upload profiles
    for (var profile in dummyProfiles) {
      await createProfile(profile);
    }

    // Create dummy events
    final List<Event> dummyEvents = [
      Event(
        id: '1',
        createdBy: '1',
        location: "Polonezköy Nature Park",
        coordinates: LatLng(41.1186, 29.1307),
        date: DateTime.now().add(Duration(days: 1, hours: 3)),
        descriptionMini: "Forest Clean-Up at Polonezköy Nature Park!",
        eventPhotoPath: "assets/nature_photos/orman_photo.jpg",
        descriptionLarge: "Hello Nature Guardians! \nJoin us at the serene Polonezköy Nature Park for a "
            "meaningful forest clean-up event. This effort aims to raise awareness about land pollution in"
            " natural parks and promote collective responsibility for protecting our green spaces. Together, "
            "we'll help preserve the purity of this beloved forest while building a stronger environmental community.",
        where: "Polonezköy Tabiat Parkı - We'll meet at the main entrance gate",
        // ... diğer event özellikleri
      ),
      // ... diğer dummy etkinlikler
    ];

    // Upload events
    for (var event in dummyEvents) {
      await createEvent(event);
    }
  }
  */
}