import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_snapshot/Message/Message.dart';
import 'package:share_snapshot/ShowAllFriendsOfFriends/ShowAllFriendsOfFriends.dart';
import 'package:share_snapshot/Widgets/CustomRaisedButton.dart';
import 'package:share_snapshot/Widgets/FriendCarouselBack.dart';
import 'package:share_snapshot/Widgets/ShowFriendsOfFriends.dart';

import '../Colors.dart';

class FriendProfile extends StatefulWidget {
  Map friendinfo;

  FriendProfile(this.friendinfo);

  @override
  _FriendProfileState createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Firestore firestore = Firestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String statusText, emailAddress;

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: Colors.white,
      body: isLoading
          ? SpinKitSquareCircle(
              color: DarkBack,
            )
          : SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height / 2,
                            child: FriendCarouselBack(
                                widget.friendinfo['frienduid'])),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              CustomRaisedButton(
                                buttonText: "Message",
                                buttonColor: DarkBack,
                                onpress: () {
Navigator.push(context, MaterialPageRoute(builder: (context)=> Message(widget.friendinfo['name'],widget.friendinfo['image'],widget.friendinfo['frienduid'])));
                                },
                              ),
                              CustomRaisedButton(
                                buttonText: "Unfriend",
                                buttonColor: Colors.red,
                                onpress: () {},
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Friends",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: DarkBack),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShowAllFriendsOfFriends(
                                                        widget.friendinfo[
                                                            'frienduid'],
                                                        widget.friendinfo[
                                                            'name'])));
                                      },
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 130,
                                child: ShowFriendsOfFriends(
                                    widget.friendinfo['frienduid']),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 2,
                                color: AltText,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "About",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: DarkBack),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                statusText,
                                style: TextStyle(fontSize: 16, color: AltText),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Email Address",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: DarkBack),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                emailAddress,
                                style: TextStyle(fontSize: 16, color: AltText),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 3,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return FullScreenImage(
                                    widget.friendinfo['image']);
                              }));
                            },
                            child: ClipOval(
                              child: Image.network(widget.friendinfo['image'],
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 4,
                                  fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.friendinfo['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: DarkBack,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            widget.friendinfo['briefinfo'],
                            style: TextStyle(
                                fontSize: 18,
                                color: DarkBack,
                                decoration: TextDecoration.none),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> loadProfileInfo() async {
    var user = await auth.currentUser();
    await firestore
        .collection('users')
        .document(widget.friendinfo['frienduid'])
        .get()
        .then((value) {
      setState(() {
        statusText = value['status'];
        emailAddress = value['email'];
      });
    });
    setState(() {
      isLoading = false;
    });
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageURL;

  FullScreenImage(this.imageURL);

  @override
  Widget build(BuildContext context) {
    print(imageURL);
    return Scaffold(
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(
            imageURL,
          ),
        ),
      ),
    );
  }
}
