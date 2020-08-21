import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';
import 'package:share_snapshot/Widgets/CustomRaisedButton.dart';

import '../Colors.dart';

class CreateProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateProfile();
  }
}

class _CreateProfile extends State<CreateProfile> {
  Firestore firestore = Firestore.instance;
  File profileImage = null;
  String username, briefinfo, status;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  Future getImage() async {
    final picker = ImagePicker();
    await picker.getImage(source: ImageSource.gallery).then((image) async {
      await cropImage(image.path, File(image.path));
    });
  }

  Future<void> cropImage(String path, File temp) async {
    File cropped =
        await ImageCropper.cropImage(sourcePath: path, compressQuality: 20);
    setState(() {
      profileImage = cropped == null ? null : cropped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      body: isLoading
          ? SpinKitSquareCircle(
              color: DarkBack,
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Create Your Profile",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: DarkBack,
                            decoration: TextDecoration.none),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: getImage,
                        child: Stack(
                          children: <Widget>[
                            ClipOval(
                              child: profileImage == null
                                  ? Image.asset(
                                      'assets/images/profile.png',
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      height:
                                          MediaQuery.of(context).size.width / 4,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(profileImage,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      height:
                                          MediaQuery.of(context).size.width / 4,
                                      fit: BoxFit.cover),
                            ),
                            Positioned(
                                bottom: MediaQuery.of(context).size.width / 200,
                                right: MediaQuery.of(context).size.width / 50,
                                child: ClipOval(
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                14,
                                        width:
                                            MediaQuery.of(context).size.width /
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
                        height: 30,
                      ),
                      TextField(
                        onChanged: (value) {
                          username = value;
                        },
                        maxLength: 20,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.person),
                          hintText: "Username",
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        onChanged: (value) {
                          briefinfo = value;
                        },
                        maxLength: 20,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.accessibility),
                          hintText: "A word that describes you",
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        onChanged: (value) {
                          status = value;
                        },
                        maxLength: 100,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.edit),
                          hintText: "Status",
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      CustomRaisedButton(
                        buttonText: "Create",
                        buttonColor: Colors.black,
                        onpress: () {
                          if (username == null ||
                              briefinfo == null ||
                              status == null ||
                              username == "" ||
                              briefinfo == "" ||
                              status == "") {
                            final Snack = SnackBar(
                              content: Text("Please enter all the fields"),
                            );
                            _scaffold.currentState.showSnackBar(Snack);
                          } else if (profileImage == null) {
                            final Snack = SnackBar(
                              content: Text("Please Choose a profile Image"),
                            );
                            _scaffold.currentState.showSnackBar(Snack);
                          } else {
                            createprofile();
                            setState(() {
                              isLoading = true;
                            });
                          }
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> createprofile() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('profilephoto')
        .child(firebaseUser.uid);
    StorageUploadTask uploadTask = storageReference.putFile(profileImage);
    await uploadTask.onComplete;
    print('File Uploaded');

    storageReference.getDownloadURL().then((fileURL) {
      firestore.collection("users").document(firebaseUser.uid).setData({
        "name": username,
        "briefinfo": briefinfo,
        "status": status,
        "profileimage": fileURL,
        "email": firebaseUser.email,
      }).then((_) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    });
  }
}
