import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:share_snapshot/FriendRequests/FriendRequests.dart';
import 'package:share_snapshot/Login/Login.dart';
import 'package:share_snapshot/Profile/Profile.dart';
import 'package:share_snapshot/ShowAllFriends/ShowAllFriends.dart';

import '../Colors.dart';

class HomescreenSideMenu extends StatefulWidget {
  @override
  _HomescreenSideMenuState createState() => _HomescreenSideMenuState();
}

class _HomescreenSideMenuState extends State<HomescreenSideMenu> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Firestore firestore = Firestore.instance;

  String username, briefinfo, imageURL;

  File profileImage = null;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  Future getImage() async {
    final picker = ImagePicker();
    await picker.getImage(source: ImageSource.gallery).then((image) async {
      await cropImage(image.path,File(image.path));
    });
    if (profileImage != null) {
      addImage();
    }
  }

  Future<void> cropImage(String path, File temp) async {
    File cropped = await ImageCropper.cropImage(sourcePath: path,compressQuality: 50);
    setState(() {
      profileImage = cropped == null ? null : cropped;
    });
  }

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
      backgroundColor: DarkBack,
      body: isLoading
          ? Container(
              width: 0.6 * MediaQuery.of(context).size.width,
              child: Center(
                child: SpinKitSquareCircle(
                  color: Colors.white,
                ),
              ),
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(left: 20),
                  width: 0.6 * MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ClipOval(
                        child: Hero(
                          tag: "profileimage",
                          child: Image.network(
                            imageURL,
                            width: MediaQuery.of(context).size.width / 2.8,
                            height: MediaQuery.of(context).size.width / 2.8,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Hero(
                        tag: "profilename",
                        child: Text(
                          username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                              decoration: TextDecoration.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Hero(
                        tag: "profileinfo",
                        child: Text(
                          briefinfo,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              decoration: TextDecoration.none),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          print(username);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Profile(imageURL, username, briefinfo)));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.account_circle,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "  My Profile",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "  Add Picture",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>FriendRequests()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.person_add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "  Friend Requests",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowAllFriends()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.people,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "  Show Friends",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          auth.signOut();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.exit_to_app,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "  Logout",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> loadProfileInfo() async {

    var user = await auth.currentUser();
    await firestore.collection('users').document(user.uid).get().then((value) {
      username = value["name"];
      briefinfo = value["briefinfo"];
      imageURL = value["profileimage"];
    });
  }

  Future<void> addImage() async {
    setState(() {
      isLoading = true;
    });
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('userphoto')
        .child(firebaseUser.uid)
        .child(path.basenameWithoutExtension(profileImage.path));
    StorageUploadTask uploadTask = storageReference.putFile(profileImage);
    await uploadTask.onComplete;
    print('File Uploaded');

    storageReference.getDownloadURL().then((fileURL) {
      firestore
          .collection("users")
          .document(firebaseUser.uid)
          .collection("photos")
          .add({"photourl": fileURL}).then((value) {
        setState(() {
          profileImage = null;
          isLoading = false;
          final Snack = SnackBar(
            content: Text("Photo Added Successfully"),
          );
          _scaffold.currentState.showSnackBar(Snack);
        });
      });
    });
  }


}
