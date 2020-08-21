import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/FriendProfile/ShowFriendGallery.dart';
import 'package:share_snapshot/Profile/ShowGallery.dart';

class FriendCarouselBack extends StatefulWidget {

  String friendUID;
  FriendCarouselBack(this.friendUID);
  @override
  _FriendCarouselBackState createState() => _FriendCarouselBackState();
}

class _FriendCarouselBackState extends State<FriendCarouselBack> {
  List<NetworkImage> imagesList = [];

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SpinKitDoubleBounce(
      color: DarkBack,
    )
        : imagesList.length == 0
        ? Center(
      child: Text("NO PHOTO"),
    )
        : GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowFriendGallery(widget.friendUID),
          ),
        );
      },
      child: Carousel(
        autoplayDuration: Duration(seconds: 3),
        images: imagesList,
        showIndicator: false,
        borderRadius: false,
        noRadiusForIndicator: true,
        overlayShadow: true,
        overlayShadowColors: Colors.white,
        overlayShadowSize: 1,
      ),
    );
  }

  Future<void> fetchPhotos() async {
    Firestore firestore = Firestore.instance;
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    await firestore
        .collection("users")
        .document(widget.friendUID)
        .collection("photos")
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          imagesList.add(NetworkImage(result["photourl"].toString()));
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }
}
