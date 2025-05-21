import 'package:flutter/material.dart';

class FollowingsPage extends StatelessWidget {
  const FollowingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followings'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('user1@example.com'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('user2@example.com'),
          ),
        ],
      ),
    );
  }
} 