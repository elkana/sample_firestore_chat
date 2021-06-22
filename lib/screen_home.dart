import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'screen_chat.dart';

class ScreenHome extends StatefulWidget {
  final String title;
  const ScreenHome({Key? key, required this.title}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isloggedin = false;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("Login");
      }
    });
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();

    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  String getGroupChatId(Map<String, dynamic> peer) {
    if (user!.uid.hashCode <= peer['id'].hashCode) {
      return user!.uid + '_' + peer['id'];
    } else {
      return peer['id'] + '_' + user!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Users'),
          actions: [
            ElevatedButton(
              onPressed: signOut,
              child: Text('Logout'),
            ),
          ],
        ),
        body: !isloggedin
            ? CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  Text(
                      "Hello ${user?.displayName ?? 'No Name'}\nyou are Logged in as ${user?.email ?? 'No Email'}"),
                  Divider(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chat_users')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return Text('Something went wrong');

                        if (snapshot.connectionState == ConnectionState.waiting)
                          return CircularProgressIndicator();

                        if (!snapshot.hasData)
                          return Text('No Registered Users');

                        List<Widget> list = [];

                        for (var data in snapshot.data!.docs) {
                          Map<String, dynamic> peer =
                              data.data() as Map<String, dynamic>;

                          if (peer['email'] == user!.email) continue;
                          list.add(ListTile(
                            title: Text(peer['name']),
                            subtitle: Text(peer['email']),
                            onTap: () {
                              String _grpId = getGroupChatId(peer);

                              print('GroupId = $_grpId');
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => ScreenChat(
                                      loginId: user!.uid,
                                      chatTo: peer,
                                      conversationId: _grpId)));
                            },
                          ));

                          print('friend -> ' +
                              peer['name'] +
                              ' | ' +
                              peer['email']);
                        }

                        if (list.length < 1) return Text('No Friends to chat');

                        return ListView(
                          children: list,
                        );
                        // return new ListView(
                        //   children: snapshot.data!.docs
                        //       .map((DocumentSnapshot document) {
                        //     Map<String, dynamic> data =
                        //         document.data() as Map<String, dynamic>;
                        //     return new ListTile(
                        //       title: new Text(data['name']),
                        //       subtitle: new Text(data['email']),
                        //     );
                        //   }). toList(),
                        // );
                      },
                    ),
                  ),
                ],
              ));
  }
}
