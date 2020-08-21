import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Colors.dart';

class ShowFriendsOfFriends extends StatefulWidget {

  String friendUID;

  ShowFriendsOfFriends(this.friendUID);

  @override
  _ShowFriendsOfFriendsState createState() => _ShowFriendsOfFriendsState();
}

class _ShowFriendsOfFriendsState extends State<ShowFriendsOfFriends> {
  List<String> friendlistUID = [];
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
        : friendlistUID.isEmpty? Center(child: Text("No Friends to Show")):
            ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friendList.length,
            shrinkWrap: true,
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
                        margin: EdgeInsets.only(top: 5), child: Text(friendList[index]['name'])),
                  ],
                ),
              );
            });
  }

  Future<void> fetchFriendsUID() async {
    await firestore
        .collection("users")
        .document(widget.friendUID)
        .collection('friends')
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          friendlistUID.add(result["friendUID"].toString());
        });
      });
    });

    if (friendlistUID.isNotEmpty) {
      fetchFriends();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFriends() async {
    friendlistUID.forEach((element) async {
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
