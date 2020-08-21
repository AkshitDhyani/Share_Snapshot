import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/CreateProfile/CreateProfile.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Register();
  }
}

class _Register extends State<Register> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  String email, pass, confirmpass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    confirmpass = value;
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
                    prefixIcon: Icon(Icons.autorenew),
                    hintText: "Confirm Password",
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 30),
                    child: GestureDetector(
                      onTap: () {
                        if (email == null ||
                            pass == null ||
                            confirmpass == null || email == "" ||
                            pass == "" ||
                            confirmpass == "") {
                          final Snack = SnackBar(
                            content: Text("Please enter all the fields"),
                          );
                          _scaffold.currentState.showSnackBar(Snack);
                        } else if (pass != confirmpass) {
                          final Snack = SnackBar(
                            content: Text("Password Doesn't Match"),
                          );
                          _scaffold.currentState.showSnackBar(Snack);
                        } else if (pass.length < 6) {
                          final Snack = SnackBar(
                            content: Text("Password must exceed 6 characters"),
                          );
                          _scaffold.currentState.showSnackBar(Snack);
                        } else {
                          createuser();
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createuser() async {
    FirebaseUser user;
    try {
      AuthResult result = await auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      user = result.user;
      print(user.toString());
    } catch (e) {
      print(e);
    } finally {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateProfile()));
      }
    }
  }
}
