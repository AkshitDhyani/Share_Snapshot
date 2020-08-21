import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/CreateProfile/CreateProfile.dart';
import 'package:share_snapshot/Login/Login.dart';
import 'package:share_snapshot/Message/Message.dart';
import 'package:share_snapshot/SearchPeople/SearchPeople.dart';
import 'package:share_snapshot/Widgets/HomescreenSideMenu.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  AnimationController _controller;
  Animation scaleAnimation;

  FirebaseAuth auth = FirebaseAuth.instance;

  List<String> friendUID = [];
  List<Map> friendList = [];

  bool isLoading = true;

  Firestore firestore = Firestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isUserLoggedIn();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    scaleAnimation = Tween<double>(begin: 1, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: DarkBack,
        body: Stack(
          children: <Widget>[
            HomescreenSideMenu(),
            MainScreen(context),
          ],
        ),
      ),
    );
  }

  Widget MainScreen(context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: isCollapsed ? 0 : 0.6 * MediaQuery.of(context).size.width,
      right: isCollapsed ? 0 : -0.4 * MediaQuery.of(context).size.width,
      top: 0,
      bottom: 0,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 8,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isCollapsed)
                                _controller.forward();
                              else
                                _controller.reverse();

                              isCollapsed = !isCollapsed;
                            });
                          },
                          child: Icon(Icons.menu)),
                      Container(
                        margin: EdgeInsets.only(left: 25),
                        child: Text(
                          "Home",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPeople()));
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : friendList.length<1?Center(child: Text("No messages"),):ListView.builder(
                          shrinkWrap: true,
                          itemCount: friendList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Message(
                                                  friendList[index]['name'],
                                                  friendList[index]['image'],
                                                  friendList[index]
                                                      ['frienduid'])));
                                    },
                                    child: Card(
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
                                                  friendList[index]
                                                      ['briefinfo'],
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
                                  ),
                                ],
                              ),
                            );
                          }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void isUserLoggedIn() async {
    FirebaseUser user = await auth.currentUser();

    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      DocumentReference reference =
          Firestore.instance.document('users/' + user.uid);
      reference.snapshots().listen((snapshot) {
        if (!snapshot.exists) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateProfile()));
        } else {
        fetchFriendsUID();
        }
      });
    }
  }

  Future<void> fetchFriendsUID() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    print(firebaseUser.uid);
    await firestore
        .collection("users")
        .document(firebaseUser.uid)
        .collection('messages')
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        print(result.data);
        setState(() {
          friendUID.add(result['uid']);
        });
      });

      if (friendUID.isNotEmpty) {
        print("hello");
        fetchFriends();
      } else {
        setState(() {
          print("bie");
          isLoading = false;
        });
      }
    });
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
