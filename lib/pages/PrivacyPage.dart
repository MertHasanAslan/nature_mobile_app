import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Private Account'),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Show Activity Status'),
            trailing: Switch(value: true, onChanged: null),
          ),
        ],
      ),
    );
  }
} 