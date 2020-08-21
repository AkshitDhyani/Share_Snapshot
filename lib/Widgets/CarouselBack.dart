import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/Profile/ShowGallery.dart';

class CarouselBack extends StatefulWidget {
  @override
  _CarouselBackState createState() => _CarouselBackState();
}

class _CarouselBackState extends State<CarouselBack> {
  List<CachedNetworkImage> imagesList = [];

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
                child: Text("Add Some Photos First"),
              )
            : Carousel(
              autoplayDuration: Duration(seconds: 3),
              images: imagesList,
              showIndicator: false,
              borderRadius: false,
              noRadiusForIndicator: true,
              overlayShadow: true,
              overlayShadowColors: Colors.white,
              overlayShadowSize: 1,
            );
  }

  Future<void> fetchPhotos() async {
    Firestore firestore = Firestore.instance;
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    await firestore
        .collection("users")
        .document(firebaseUser.uid)
        .collection("photos")
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          imagesList.add(CachedNetworkImage(
            imageUrl: result["photourl"],
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            fit: BoxFit.cover,
          ));
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }
}
