import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Colors.dart';

class ShowFriends extends StatefulWidget {
  @override
  _ShowFriendsState createState() => _ShowFriendsState();
}

class _ShowFriendsState extends State<ShowFriends> {
  List<String> friendUID = [];
  List<Map> friendList = [];

  bool isLoading = true;

  Firestore firestore = Firestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFriendsUID();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SpinKitDoubleBounce(
            color: DarkBack,
          )
        : friendUID.isEmpty
            ? Center(child: Text("No Friends to Show"))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friendList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        ClipOval(
                          child: Image.network(
                            friendList[index]['image'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(friendList[index]['name'])),
                      ],
                    ),
                  );
                });
  }

  Future<void> fetchFriendsUID() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    await firestore
        .collection("users")
        .document(firebaseUser.uid)
        .collection('friends')
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          friendUID.add(result["friendUID"].toString());
        });
      });
    });

    if (friendUID.isNotEmpty) {
      fetchFriends();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFriends() async {
    friendUID.forEach((element) async {
      await firestore.collection("users").document(element).get().then((value) {
        var usermap = new Map();
        String tempname = value['name'];
        var temp = tempname.split(" ");
        usermap['name'] = temp[0];
        usermap['image'] = value['profileimage'];
        usermap['frienduid'] = element;
        setState(() {
          friendList.add(usermap);
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }
}
