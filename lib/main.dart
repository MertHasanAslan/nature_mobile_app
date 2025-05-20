import 'package:flutter/material.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:cs_projesi/widgets/eventCardWidget.dart';
import 'package:cs_projesi/widgets/storyBarWidget.dart';
import 'package:cs_projesi/widgets/navigationBarWidget.dart';
import 'package:cs_projesi/pages/homePage.dart';
import 'package:cs_projesi/pages/eventPage.dart';
import 'package:cs_projesi/pages/profileCreation.dart';
import 'package:cs_projesi/pages/questionMarkPage.dart';
import 'package:cs_projesi/pages/ProfilePage.dart';
import 'package:cs_projesi/pages/SettingsPage.dart';
import 'package:cs_projesi/pages/sign_in_page.dart';
import 'package:cs_projesi/pages/sign_up_page.dart';
import 'package:cs_projesi/pages/mapPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';
import 'firebase_options.dart';

/*
Future<void> ensureDummyDataUploaded() async {
  final firebaseService = FirebaseService();
  try {
    await firebaseService.uploadDummyData();
    print('Dummy data uploaded successfully');
  } catch (e) {
    print('Error uploading dummy data: $e');
  }
}
*/

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // await ensureDummyDataUploaded();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NatureSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'RobotoSerif',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInPage(),
        '/SignUp': (context) => const SignUpPage(),
        '/ProfileCreation': (context) => ProfileCreationPage(),
        '/HomePage': (context) => HomePage(),
        '/EventPage': (context) =>
            EventPage(event: ModalRoute.of(context)!.settings.arguments as Event),
        '/SettingsPage': (context) => const SettingsPage(),
        '/MapPage': (context) => const MapPage(),
        '/QuestionMarkPage': (context) => const QuestionMarkPage(),
        '/ProfilePage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Map && args['profile'] is Profile) {
            return ProfilePage(
              user: args['profile'],
              isOwnProfile: args['isOwnProfile'] ?? false,
            );
          }
          return Scaffold(body: Center(child: Text('No profile data')));
        },
      },
    );
  }
}