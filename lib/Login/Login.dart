import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/CreateProfile/CreateProfile.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';
import 'package:share_snapshot/Register/Register.dart';
import 'package:share_snapshot/Widgets/CustomRaisedButton.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  String email, pass;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffold,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Hero(
                    tag: "appname",
                    child: Text(
                      "SharE SnapshoT",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          color: DarkBack,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  SizedBox(height: 20),
                  Hero(
                    tag: "image",
                    child: Container(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Image.asset(
                          'assets/images/login.png',
                          fit: BoxFit.cover,
                        )),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    onChanged: (value) {
                      email = value;
                    },
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
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      pass = value;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Password",
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                        child: Text(
                          "New User?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (email == null ||
                              pass == null ||
                              email == "" ||
                              pass == "") {
                            final Snack = SnackBar(
                              content: Text("Please enter all the fields"),
                            );
                            _scaffold.currentState.showSnackBar(Snack);
                          } else {
                            loginUser();
                          }
                        },
                        child: ClipOval(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            color: DarkBack,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Text(
                    "or connect using",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CustomRaisedButton(
                          buttonText: "Facebook",
                          buttonColor: Colors.blue,
                          onpress: () {},
                        ),
                        CustomRaisedButton(
                          buttonText: "Google",
                          buttonColor: Colors.red,
                          onpress: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    FirebaseUser user;
    try {
      AuthResult result =
          await auth.signInWithEmailAndPassword(email: email, password: pass);
      user = result.user;
      print(user.toString());
    } catch (e) {
      print(e);
    } finally {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
  }
}
