import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_snapshot/Colors.dart';
import 'package:share_snapshot/HomeScreen/HomeScreen.dart';

class Message extends StatefulWidget {
  String name, image, fuid;

  Message(this.name, this.image, this.fuid);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Firestore firestore = Firestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController message = TextEditingController();

  String myuid = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return HomeScreen();
                          }));
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        widget.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    ClipOval(
                      child: Image.network(
                          widget.image,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover),
                    ),
                  ],
                ),
                myuid == null
                    ? Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection("users")
                            .document(myuid)
                            .collection('messages')
                            .document(widget.fuid)
                            .collection('messages')
                            .orderBy('time', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Map> messageList = [];
                            final messages = snapshot.data.documents.reversed;
                            for (var message in messages) {
                              var messagemap = new Map();
                              messagemap['message'] = message.data['message'];
                              messagemap['person'] = message.data['person'];
                              messageList.add(messagemap);
                            }
                            return Expanded(
                              child: ListView.builder(
                                reverse: true,
                                  shrinkWrap: true,
                                  itemCount: messageList.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return Column(
                                      crossAxisAlignment: messageList[index]
                                                  ['person'] ==
                                              "notme"
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Card(
                                            elevation:8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: messageList[index]
                                              ['person'] ==
                                                  "notme"
                                                  ? BorderRadius.only(
                                                bottomLeft:
                                                Radius.circular(10),
                                                topRight:
                                                Radius.circular(10),
                                                bottomRight:
                                                Radius.circular(10),
                                              )
                                                  : BorderRadius.only(
                                                bottomLeft:
                                                Radius.circular(10),
                                                topLeft:
                                                Radius.circular(10),
                                                bottomRight:
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: messageList[index]
                                                            ['person'] ==
                                                        "notme"
                                                    ? BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      )
                                                    : BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        topLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      ),
                                                color: messageList[index]
                                                            ['person'] ==
                                                        "notme"
                                                    ? DarkBack
                                                    : Colors.white,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  messageList[index]['message'],
                                                  style: TextStyle(
                                                    color: messageList[index]
                                                                ['person'] ==
                                                            "notme"
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            );
                          } else {
                            return Expanded(child: Center(child: Text("No Messages")));
                          }
                        },
                      ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: message,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: "Enter Message",
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.send,
                            size: 30,
                          ),
                        )),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Future<void> sendMessage() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestore.settings(persistenceEnabled: true);

    firestore.collection("users").document(firebaseUser.uid).collection('messages').document(widget.fuid).setData(
        {
          "uid": widget.fuid,
        }).then((_){
      firestore.collection("users").document(widget.fuid).collection('messages').document(firebaseUser.uid).setData(
          {
            "uid": firebaseUser.uid,
          }).then((_){
          print("success");
      });
    });

    firestore
        .collection("users")
        .document(firebaseUser.uid)
        .collection('messages')
        .document(widget.fuid)
        .collection('messages')
        .add({
      "message": message.text,
      "person": "me",
      "time":DateTime.now(),
    }).then((_) {
      firestore
          .collection("users")
          .document(widget.fuid)
          .collection('messages')
          .document(firebaseUser.uid)
          .collection('messages')
          .add({
        "message": message.text,
        "person": "notme",
        "time":DateTime.now(),
      }).then((_) {
        setState(() {
          message.clear();
        });
      });
    });
  }

  Future<void> getCurrentUser() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      myuid = firebaseUser.uid;
    });
  }
}
