import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';
import 'package:share_snapshot/ShowAllFriends/ShowAllFriends.dart';
import 'package:share_snapshot/Widgets/CarouselBack.dart';
import 'package:share_snapshot/Widgets/CustomRaisedButton.dart';
import 'package:share_snapshot/Widgets/ShowFriends.dart';

import 'ShowGallery.dart';

class Profile extends StatefulWidget {
  String imageURL, username, briefinfo;

  Profile(this.imageURL, this.username, this.briefinfo);

  @override
  State<StatefulWidget> createState() {
    return _Profile();
  }
}

class _Profile extends State<Profile> {
  String statusText, emailAddress;
  TextEditingController statusController = TextEditingController();
  Firestore firestore = Firestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  File profileImage = null;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  Future getImage() async {
    final picker = ImagePicker();
    await picker.getImage(source: ImageSource.gallery).then((image) async {
      await cropImage(image.path,File(image.path));
    });
    if (profileImage != null) {
      changeProfilePhoto();
    }
  }
  Future<void> cropImage(String path, File temp) async {
    File cropped = await ImageCropper.cropImage(sourcePath: path,compressQuality: 20);
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                          Stack(
                            children: <Widget>[
                              Container(
                                  height: MediaQuery.of(context).size.height / 2,
                                  child: CarouselBack()),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowGallery(),
                                    ),
                                  );
                                },
                                child: Container(
                                    height: MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0),
                                            Colors.white.withOpacity(1)
                                          ],
                                      )
                                    ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
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
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowAllFriends()));
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
                                  child: ShowFriends(),
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
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16,
                                                      16,
                                                      16,
                                                      MediaQuery.of(context)
                                                          .viewInsets
                                                          .bottom),
                                                  child: _ChangeStatus(context),
                                                ),
                                              );
                                            });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  statusText,
                                  style:
                                      TextStyle(fontSize: 16, color: AltText),
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
                                  style:
                                      TextStyle(fontSize: 16, color: AltText),
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
                                getImage();
                              },
                              child: Stack(
                                children: <Widget>[
                                  ClipOval(
                                    child: Hero(
                                        tag: "profileimage",
                                        child: Image.network(widget.imageURL,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            fit: BoxFit.cover)),
                                  ),
                                  Positioned(
                                      bottom:
                                          MediaQuery.of(context).size.width /
                                              200,
                                      right: MediaQuery.of(context).size.width /
                                          50,
                                      child: ClipOval(
                                          child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  14,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  14,
                                              color: Colors.black,
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    24,
                                              )))),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Hero(
                              tag: "profilename",
                              child: Text(
                                widget.username,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: DarkBack,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            Hero(
                              tag: "profileinfo",
                              child: Text(
                                widget.briefinfo,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: DarkBack,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double>
                                              secondaryAnimation) =>
                                      HomeScreen()));
                        },
                        child: ClipOval(
                          child: Container(
                              width: 40,
                              height: 40,
                              color: Colors.white,
                              child: Icon(Icons.arrow_back_ios)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _ChangeStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 20),
        Text(
          "Change Status",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: DarkBack),
        ),
        SizedBox(height: 20),
        TextField(
          autofocus: true,
          controller: statusController,
          decoration: InputDecoration(
            hintText: statusText,
          ),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CustomRaisedButton(
              buttonText: "Cancel",
              buttonColor: Colors.red,
              onpress: () {
                setState(() {
                  Navigator.pop(context);
                  statusController.clear();
                });
              },
            ),
            CustomRaisedButton(
              buttonText: "Save",
              buttonColor: Colors.red,
              onpress: () async {
                var user = await auth.currentUser();
                statusText = statusController.text.toString();
                firestore.collection("users").document(user.uid).updateData({
                  "status": statusText,
                }).then((_) {
                  setState(() {
                    Navigator.pop(context);
                    statusController.clear();
                  });
                });
              },
            ),
          ],
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Future<void> changeProfilePhoto() async {
    setState(() {
      isLoading = true;
    });
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('profilephoto')
        .child(firebaseUser.uid);
    StorageUploadTask uploadTask = storageReference.putFile(profileImage);
    await uploadTask.onComplete;
    print('File Uploaded');

    storageReference.getDownloadURL().then((fileURL) {
      firestore
          .collection("users")
          .document(firebaseUser.uid)
          .updateData({"profileimage": fileURL}).then((value) {
        setState(() {
          widget.imageURL = fileURL;
          setState(() {
            isLoading = false;
            final Snack = SnackBar(
              content: Text("Profile Photo Changed Successfully"),
            );
            _scaffold.currentState.showSnackBar(Snack);
          });
        });
      });
    });
  }

  Future<void> loadProfileInfo() async {
    var user = await auth.currentUser();
    await firestore.collection('users').document(user.uid).get().then((value) {
      setState(() {
        statusText = value['status'];
        emailAddress = user.email;
      });
    });
  }
}
