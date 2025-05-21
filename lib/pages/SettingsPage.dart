import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cs_projesi/widgets/navigationBarWidget.dart';
import 'package:cs_projesi/pages/contactUsPage.dart'; // Make sure the import path is correct
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false); // back to SignIn
    }
  }


  Widget _buildTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'RobotoSerif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildTile(MdiIcons.accountMultiple, 'Followings', () {
            Navigator.of(context).pushNamed('/FollowingsPage');
          }),
          _buildTile(MdiIcons.accountEdit, 'Edit Profile', () {
            Navigator.of(context).pushNamed('/EditProfilePage');
          }),
          _buildTile(MdiIcons.lock, 'Privacy', () {
            Navigator.of(context).pushNamed('/PrivacyPage');
          }),
          _buildTile(MdiIcons.phone, 'Contact Us', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            );
          }),
          _buildTile(Icons.logout, 'Logout', () {
            _logout(context);
          }),
        ],
      ),
      bottomNavigationBar: NavigationBarNature(selectedIndex: _selectedIndex),
    );
  }
}


