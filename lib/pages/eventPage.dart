import 'package:flutter/material.dart';
import 'package:cs_projesi/models/profile.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:cs_projesi/widgets/eventCardWidget.dart';
import 'package:cs_projesi/widgets/storyBarWidget.dart';
import 'package:cs_projesi/widgets/navigationBarWidget.dart';
import 'package:cs_projesi/utility_classes/eventPage_utility.dart';
import 'package:cs_projesi/utility_classes/app_colors.dart';
import 'package:cs_projesi/pages/ProfilePage.dart';
import 'package:cs_projesi/pages/showOnMapPage.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';

class EventPage extends StatefulWidget {
  final Event event;

  const EventPage({super.key, required this.event});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _selectedIndex = 2;
  bool _isRequested = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(5),
          child: AppBar()),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left:10, right: 20, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back)),
                      SizedBox(
                        width: 130,
                      ),
                      Text(
                        event.formattedDate,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontFamily: 'RobotoSerif',
                          fontSize: 18,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15, top: 10),
                        child: Container(
                          width: 300,
                          height: 80,
                          child: Text(
                            event.descriptionMini,
                            softWrap: true,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontFamily: 'RobotoSerif',
                              fontSize: 22,
                              color: Colors.black87,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
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
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8, left: 5,),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            event.eventPhotoPath,
                            height: 280,
                            width: 413,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EventPageUtility.infoTile("", event.descriptionLarge,),
                            EventPageUtility.infoTile("When:", event.when),
                            EventPageUtility.infoTile("Where:", event.where),
                            EventPageUtility.infoTile("What to bring:", event.bring),
                            EventPageUtility.infoTile("Goal:", event.goal),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRequested = !_isRequested;
                            });
                          },
                          child: Container(
                            height: 65,
                            width: 130,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isRequested ? AppColors.green.withOpacity(0.5) : Colors.white,
                              border: Border.all(color: AppColors.green, width: 3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              _isRequested ? "Sent" : "Request to join",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                letterSpacing: -0.7,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowOnMapPage(event: event),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            height: 65,
                            width: 130,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.green, width: 3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              "Show on map",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                letterSpacing: -0.7,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarNature(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}

