import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_snapshot/Colors.dart';

class FriendRequests extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FriendRequests();
  }
}

class _FriendRequests extends State<FriendRequests> {
  List<String> userUID = [];
  List<Map> userList = [];

  bool isLoading = true;

  Firestore firestore = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRequests();
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
                child: userUID.isEmpty
                    ? Center(child: Text("No Friend Requests"))
                    : ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 130,
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
                                            child: Image.network(
                                              userList[index]['image'],
                                              fit: BoxFit.cover,
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
                                                userList[index]['name'],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: DarkBack,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                userList[index]['briefinfo'],
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
                                  Positioned(
                                    bottom: 0,
                                    right: 20,
                                    child: GestureDetector(
                                      onTap: () {
                                        cancelRequest(
                                            userList[index]['frienduid']);
                                      },
                                      child: ClipOval(
                                        child: Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.red,
                                            child: Icon(
                                              Icons.clear,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 90,
                                    child: GestureDetector(
                                      onTap: () {
                                        acceptRequest(
                                            userList[index]['frienduid']);
                                      },
                                      child: ClipOval(
                                        child: Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.blue,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
              ),
            ),
    );
  }

  Future<void> fetchRequests() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    await firestore.collection("friendrequests").getDocuments().then((value) {
      value.documents.forEach((result) {
        if (result['received'] == firebaseUser.uid)
          setState(() {
            userUID.add(result["sent"].toString());
          });
      });
    });

    if (userUID.isNotEmpty) {
      fetchUsers();
    }
    else{
      setState(() {
        isLoading=false;
      });
    }
  }

  Future<void> fetchUsers() async {
    userUID.forEach((element) async {
      await firestore.collection("users").document(element).get().then((value) {
        var usermap = new Map();
        usermap['name'] = value['name'];
        usermap['briefinfo'] = value['briefinfo'];
        usermap['image'] = value['profileimage'];
        usermap['frienduid'] = element;
        setState(() {
          userList.add(usermap);
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> cancelRequest(String friendUID) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    await firestore.collection("friendrequests").getDocuments().then((value) {
      value.documents.forEach((result) {
        if (result['received'] == firebaseUser.uid &&
            result['sent'] == friendUID)
          firestore
              .collection("friendrequests")
              .document(result.documentID)
              .delete()
              .then((_) {
            setState(() {
              userUID.clear();
              userList.clear();
              fetchRequests();
              final Snack = SnackBar(
                content: Text("Friend Request Deleted Successfully"),
              );
              _scaffold.currentState.showSnackBar(Snack);
            });
          });
      });
    });
  }

  Future<void> acceptRequest(String friendUID) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestore
        .collection("users")
        .document(firebaseUser.uid)
        .collection("friends")
        .add({"friendUID": friendUID}).then((value) {
      firestore
          .collection("users")
          .document(friendUID)
          .collection("friends")
          .add({"friendUID": firebaseUser.uid}).then((value) {
        cancelRequest(friendUID);
        final Snack = SnackBar(
          content: Text("Friend Request Accepted Successfully"),
        );
        _scaffold.currentState.showSnackBar(Snack);
      });
    });
  }
}
