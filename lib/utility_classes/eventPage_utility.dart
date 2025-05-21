import 'package:flutter/material.dart';

class EventPageUtility {
  static Widget infoTile(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'RobotoSerif',
              fontSize: 21,
              color: Colors.black,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'RobotoSerif',
              fontSize: 20,
              color: Colors.black87,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 1),
        ],
      ),
    );
  }
}
