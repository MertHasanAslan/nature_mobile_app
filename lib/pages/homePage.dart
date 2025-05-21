import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cs_projesi/providers/auth_provider.dart';
import 'package:cs_projesi/providers/events_provider.dart';
import 'package:cs_projesi/providers/profiles_provider.dart';
import 'package:cs_projesi/widgets/eventCardWidget.dart';
import 'package:cs_projesi/widgets/storyBarWidget.dart';
import 'package:cs_projesi/widgets/navigationBarWidget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final currentProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NatureSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/EventAddPage');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Story Bar
          const StoryBarWidget(),
          
          // Events List
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(
                    child: Text('No events available'),
                  );
                }
                return ListView.builder(
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
          ),
        ],
      ),
      bottomNavigationBar: const NavigationBarNature(selectedIndex: 2),
    );
  }
}