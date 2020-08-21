import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_snapshot/Colors.dart';

final String heroTag = "hey";

class ShowFriendGallery extends StatefulWidget {

  String friendUID;

  ShowFriendGallery(this.friendUID);
  @override
  State<StatefulWidget> createState() {
    return _ShowFriendGallery();
  }
}

class _ShowFriendGallery extends State<ShowFriendGallery> {
  List<String> imagesList = [];

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? SpinKitDoubleBounce(
        color: DarkBack,
      )
          : StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: imagesList.length,
        itemBuilder: (BuildContext context, int index) => Card(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return FullScreenImage(imagesList[index].toString());
                  }));
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imagesList[index])),
              ),
            ],
          ),
        ),
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
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
          imagesList.add(result["photourl"].toString());
        });
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
