

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Colors.dart';

class SearchPeople extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPeople();
  }
}

class _SearchPeople extends State<SearchPeople> {
  String searchemail = null,
      name = null,
      briefinfo,
      imageurl,
      documentID = null,
      deletedocument = null;

  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  bool isRequestSent = false, isFriend = false;

  Firestore firestore = Firestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckRequestStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width /1.5,
                    child: TextField(
                      onChanged: (value) {
                        searchemail = value;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: "Enter Email",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      fetchsearchdata();
                      setState(() {
                        name = null;
                        briefinfo = null;
                        imageurl = null;
                        isLoading = true;
                        isFriend=false;
                      });
                    },
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              searchemail == null
                  ? Column(
                      children: <Widget>[
                        SizedBox(
                          height: 50,
                        ),
                        Text("Nothing to Show"),
                      ],
                    )
                  : isLoading
                      ? SpinKitDoubleBounce(
                          color: DarkBack,
                        )
                      : name == null
                          ? Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
                                ),
                                Text("No Results Found"),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                elevation: 10,
                                child: Stack(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        imageurl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: isFriend? Container(

                                        width: 150,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(child: Text("Friend Already",style: TextStyle(
                                          fontSize: 18,fontWeight: FontWeight.bold
                                        ),)),
                                      ):GestureDetector(
                                        onTap: () {
                                          isRequestSent
                                              ? cancelRequest()
                                              : sendRequest();
                                        },
                                        child: ClipOval(
                                          child: Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.white,
                                              child: isRequestSent
                                                  ? Icon(Icons.clear)
                                                  : Icon(Icons.person_add)),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Stack(
                                              children: <Widget>[
                                                // Stroked text as border.
                                                Text(
                                                  name.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    foreground: Paint()
                                                      ..style =
                                                          PaintingStyle.stroke
                                                      ..strokeWidth = 6
                                                      ..color = DarkBack,
                                                  ),
                                                ),
                                                // Solid text as fill.
                                                Text(
                                                  name.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Stack(
                                              children: <Widget>[
                                                // Stroked text as border.
                                                Text(
                                                  briefinfo.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    foreground: Paint()
                                                      ..style =
                                                          PaintingStyle.stroke
                                                      ..strokeWidth = 3
                                                      ..color = DarkBack,
                                                  ),
                                                ),
                                                // Solid text as fill.
                                                Text(
                                                  briefinfo.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
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
                              ),
                            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchsearchdata() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    print(searchemail);
    Firestore firestore = Firestore.instance;

    await firestore.collection("users").document(firebaseUser.uid).collection('friends').getDocuments().then((value) {
      value.documents.forEach((result) async {

        await firestore.collection("users").document(result['friendUID']).get().then((value){
          if (searchemail == value["email"]) {
            setState(() {
              isFriend= true;
            });
          }
        } );

      });
    });
    if(isFriend==false) {
      if (searchemail == firebaseUser.email) {
        final Snack = SnackBar(
          content: Text("This is your email"),
        );
        _scaffold.currentState.showSnackBar(Snack);
      }
      else {
        await firestore.collection("users").getDocuments().then((value) {
          value.documents.forEach((result) {
            if (searchemail == result["email"]) {
              setState(() {
                documentID = result.documentID;
                name = result["name"];
                briefinfo = result["briefinfo"];
                imageurl = result["profileimage"];
              });
            }
          });
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> sendRequest() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestore
        .collection("friendrequests")
        .add({"sent": firebaseUser.uid, "received": documentID}).then((value) {
      setState(() {
        isRequestSent = true;
        final Snack = SnackBar(
          content: Text("Friend Request Sent"),
        );
        _scaffold.currentState.showSnackBar(Snack);
      });
    });
  }

  Future<void> CheckRequestStatus() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestore.collection("friendrequests").getDocuments().then((value) => {
          value.documents.forEach((result) {
            if (result["sent"] == firebaseUser.uid) {
              setState(() {
                isRequestSent = true;
              });
            }
          })
        });
  }

  cancelRequest() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestore.collection("friendrequests").getDocuments().then((value) {
      value.documents.forEach((result) {
        if (result["sent"] == firebaseUser.uid) {
          setState(() {
            deletedocument = result.documentID;
            firestore
                .collection("friendrequests")
                .document(deletedocument)
                .delete()
                .then((_) {
              setState(() {
                deletedocument = null;
                isRequestSent = false;
                final Snack = SnackBar(
                  content: Text("Friend Request Cancelled"),
                );
                _scaffold.currentState.showSnackBar(Snack);
              });
            });
          });
        }
      });
    });
  }
}
