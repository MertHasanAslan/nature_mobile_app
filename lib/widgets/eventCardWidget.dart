import 'package:flutter/material.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';
import 'package:cs_projesi/pages/ProfilePage.dart';

class EventCardWidget extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final FirebaseService _firebaseService = FirebaseService();

  EventCardWidget({
    Key? key,
    required this.event,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 18, bottom: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: Colors.white54,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FutureBuilder<Profile?>(
                  future: _firebaseService.getProfile(event.createdBy),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      );
                    }

                    final profile = snapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                              user: profile,
                              isOwnProfile: false,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: profile.profilePhotoPath.startsWith('http')
                            ? NetworkImage(profile.profilePhotoPath)
                            : AssetImage(profile.profilePhotoPath) as ImageProvider,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 5),
                FutureBuilder<Profile?>(
                  future: _firebaseService.getProfile(event.createdBy),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                      return const Text(
                        'Loading...',
                        style: TextStyle(
                          fontFamily: 'RobotoSerif',
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }

                    return Text(
                      snapshot.data!.name,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontFamily: 'RobotoSerif',
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const Spacer(),
                Text(
                  event.formattedDate,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: 'RobotoSerif',
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.location_on_outlined, size: 25, color: Colors.black45),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: (){},
                  child: SizedBox(
                    width: 100,
                    child: Text(
                      event.location,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontFamily: 'RobotoSerif',
                        fontSize: 15,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/EventPage',
                      arguments: event,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                    child: Image.asset(
                      event.eventPhotoPath,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (onDelete != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 10),
              child: Container(
                child: Text(
                  event.descriptionMini,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'RobotoSerif',
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
