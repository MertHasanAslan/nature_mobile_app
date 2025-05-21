import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cs_projesi/pages/ProfilePage.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:cs_projesi/pages/eventPage.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';

class ShowOnMapPage extends StatelessWidget {
  final Event event;

  const ShowOnMapPage({Key? key, required this.event}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show Event on Map"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: event.coordinates,
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
                  markers: [
                    Marker(
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
                                    future: FirebaseService().getProfile(event.createdBy),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.grey[300],
                                        );
                                      }

                                      if (snapshot.hasError || !snapshot.hasData) {
                                        return CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.grey[300],
                                          child: Icon(Icons.person, color: Colors.grey[600]),
                                        );
                                      }

                                      final profile = snapshot.data!;
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
