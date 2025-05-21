import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/providers/profiles_provider.dart';
import 'package:cs_projesi/providers/events_provider.dart';
import 'package:cs_projesi/widgets/navigationBarWidget.dart';
import 'package:cs_projesi/utility_classes/app_colors.dart';
import 'package:cs_projesi/widgets/eventCardWidget.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';

class ProfilePage extends ConsumerWidget {
  final Profile user;
  final bool isOwnProfile;

  const ProfilePage({
    super.key,
    required this.user,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show events for the profile's user, not just the logged-in user
    final userEventsAsync = ref.watch(eventsByUserProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: Text(
              'Age: ${user.age}',
              style: const TextStyle(fontSize: 16, fontFamily: 'RobotoSerif'),
            ),
          ),
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/SettingsPage');
              },
            ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: user.profilePhotoPath.startsWith('http')
                    ? NetworkImage(user.profilePhotoPath)
                    : AssetImage(user.profilePhotoPath) as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${user.name} ${user.surname}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'RobotoSerif',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (user.bio.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'RobotoSerif',
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (user.favoriteActivities.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Favorite Activities:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'RobotoSerif',
                  ),
                ),
              ),
            if (user.favoriteActivities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: user.favoriteActivities.map((activity) =>
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            activity,
                            style: const TextStyle(fontSize: 16, fontFamily: 'RobotoSerif'),
                          ),
                        ),
                      ],
                    )
                  ).toList(),
                ),
              ),
            if (user.favoritePlaces.isNotEmpty) ...[
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Favorite Places:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'RobotoSerif',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: user.favoritePlaces.map((place) =>
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            place,
                            style: const TextStyle(fontSize: 16, fontFamily: 'RobotoSerif'),
                          ),
                        ),
                      ],
                    )
                  ).toList(),
                ),
              ),
            ],
            const SizedBox(height: 30),
            if (!isOwnProfile)
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    // Implement follow/unfollow logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.green,
                      width: 3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: AppColors.green,
                      fontFamily: 'RobotoSerif',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // User's Events
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            userEventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No events created yet'),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCardWidget(
                      event: event,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/EventPage',
                          arguments: event,
                        );
                      },
                      onDelete: isOwnProfile ? () async {
                        // Show confirmation dialog
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Event'),
                            content: const Text('Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          // Delete event from Firebase
                          await FirebaseService().deleteEvent(event.id);
                          // Update profile's hasEvent to false
                          await FirebaseService().updateProfile(user.id, {'hasEvent': false});
                        }
                      } : null,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarNature(
        selectedIndex: 1,
      ),
    );
  }
}
