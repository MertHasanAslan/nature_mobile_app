import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cs_projesi/widgets/navigationBarWidget.dart';
import 'package:cs_projesi/pages/ProfilePage.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:cs_projesi/pages/eventPage.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  void _navigateToEvent(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPage(event: event),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, Profile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          user: profile,
          isOwnProfile: false,
        ),
      ),
    );
  }

  Future<List<Event>> _filterEventsWithProfileHasEvent(List<Event> events) async {
    final firebaseService = FirebaseService();
    List<Event> filtered = [];
    for (final event in events) {
      try {
        final profile = await firebaseService.getProfile(event.createdBy);
        if (profile != null) {
          if (event.descriptionMini != null &&
              event.eventPhotoPath != null &&
              event.location != null &&
              event.createdBy != null &&
              event.coordinates != null) {
            filtered.add(event);
          }
        }
      } catch (e) {
        // skip problematic events
        continue;
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map of Istanbul"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _firebaseService.getEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No events found'));
                }

                return FutureBuilder<List<Event>>(
                  future: _filterEventsWithProfileHasEvent(snapshot.data!),
                  builder: (context, filteredSnapshot) {
                    if (!filteredSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final filteredEvents = filteredSnapshot.data!;
                    if (filteredEvents.isEmpty) {
                      return Center(child: Text('No valid events found'));
                    }
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(41.0082, 28.9784),
                        maxZoom: 18.0,
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: filteredEvents.map((event) {
                            return Marker(
                              point: event.coordinates,
                              width: 160,
                              height: 180,
                              child: Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                event.eventPhotoPath,
                                                width: 160,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                              Container(
                                                width: 160,
                                                height: 80,
                                                color: Colors.black.withOpacity(0.2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: FutureBuilder<Profile?>(
                                            future: _firebaseService.getProfile(event.createdBy),
                                            builder: (context, profileSnapshot) {
                                              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                                                return CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.grey[300],
                                                );
                                              }

                                              if (profileSnapshot.hasError || !profileSnapshot.hasData) {
                                                return CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.grey[300],
                                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                                );
                                              }

                                              final profile = profileSnapshot.data!;
                                              return GestureDetector(
                                                onTap: () => _navigateToProfile(context, profile),
                                                child: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.white,
                                                  child: CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage: profile.profilePhotoPath.startsWith("http")
                                                        ? NetworkImage(profile.profilePhotoPath)
                                                        : AssetImage(profile.profilePhotoPath) as ImageProvider,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        event.descriptionMini,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: GestureDetector(
                                        onTap: () => _navigateToEvent(context, event),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "More",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavigationBarNature(selectedIndex: 3),
    );
  }
}
