/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../models/UserProfile.dart';

import '../data/event_data.dart';
import '../data/profile_data.dart';
import '../data/UserProfile_data.dart';

class DummyUploader {
  static Future<void> uploadAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('⚠️ Giriş yapılmamış. Dummy veri yüklenemez.');
      return;
    }

    await uploadEvents(uid);
    await uploadProfiles(uid);
    await uploadUserProfiles(uid);

    print('✅ Tüm dummy veriler yüklendi.');
  }

  static Future<void> uploadEvents(String uid) async {
    final col = FirebaseFirestore.instance.collection('events');
    for (final e in eventList) {
      final doc = col.doc();
      await doc.set(e.copyWith(
        id: doc.id,
        createdBy: uid,
        createdAt: DateTime.now(),
      ).toJson());
    }
    print('✅ Etkinlikler yüklendi.');
  }

  static Future<void> uploadProfiles(String uid) async {
    final col = FirebaseFirestore.instance.collection('profiles');
    for (final p in profileList) {
      final doc = col.doc();
      await doc.set(p.copyWith(
        id: doc.id,
        createdBy: uid,
        createdAt: DateTime.now(),
      ).toJson());
    }
    print('✅ Profiller yüklendi.');
  }

  static Future<void> uploadUserProfiles(String uid) async {
    final col = FirebaseFirestore.instance.collection('user_profiles');
    for (final up in userProfileList) {
      final doc = col.doc();
      await doc.set(up.copyWith(
        id: doc.id,
        createdBy: uid,
        createdAt: DateTime.now(),
      ).toJson());
    }
    print('✅ UserProfile verileri yüklendi.');
  }
}
*/
