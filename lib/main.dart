import 'package:flutter/material.dart';
import 'package:share_snapshot/CreateProfile/CreateProfile.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';
import 'package:share_snapshot/ShowAllFriends/ShowAllFriends.dart';



import 'Login/Login.dart';
import 'Profile/Profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Snapshot',
      home: HomeScreen(),
    );
  }
}

