import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';

import '../Colors.dart';

class ShowAllFriendsOfFriends extends StatefulWidget{

  String fuid;
  String fname;
  ShowAllFriendsOfFriends(this.fuid,this.fname);


  @override
  _ShowAllFriendsOfFriendsState createState() => _ShowAllFriendsOfFriendsState();
}

class _ShowAllFriendsOfFriendsState extends State<ShowAllFriendsOfFriends> {
  List<String> friendUID = [];
  List<Map> friendList = [];

  bool isLoading = true;

  Firestore firestore = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFriendsUID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      body: isLoading
          ? SpinKitDoubleBounce(
        color: DarkBack,
      )
          : SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: friendUID.isEmpty
              ? Center(child: Text("No Friend"))
              : Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back_ios)),
                      Container(
                        child: Text(
                          widget.fname+"'s Friends",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      SizedBox(width: 10,)
                    ],
                  ),
                  SizedBox(height: 20,),
                  ListView.builder(
                    shrinkWrap: true,
                  itemCount: friendList.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: <Widget>[
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              height: 80,
                              child: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft:
                                        Radius.circular(20)),
                                    child: Container(
                                      width: 110,
                                      child: Image.network(
                                        friendList[index]['image'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        friendList[index]['name'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: DarkBack,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        friendList[index]['briefinfo'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: AltText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
        ),
      ),
    );
  }

  Future<void> fetchFriendsUID() async {

    await firestore
        .collection("users")
        .document(widget.fuid)
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
        usermap['name'] = value['name'];
        usermap['briefinfo'] = value['briefinfo'];
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