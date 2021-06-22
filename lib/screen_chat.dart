import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'util/database.dart';

class ScreenChat extends StatefulWidget {
  final String loginId, conversationId;

  /// aka FirebaseUser, it's not using User because firestore using json since Firebase User class doesnt have default constructor.
  final Map<String, dynamic> chatTo;

  const ScreenChat(
      {Key? key,

      /// id of logged user
      required this.loginId,

      /// a concat of both user.id and peer.id
      required this.conversationId,

      /// peer id
      required this.chatTo})
      : super(key: key);

  @override
  _ScreenChatState createState() => _ScreenChatState();
}

class _ScreenChatState extends State<ScreenChat> {
  late List<DocumentSnapshot> listMessage;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  Widget buildItem(int index, DocumentSnapshot document) {
    if (!document['read'] && document['idTo'] == widget.loginId) {
      // Database.updateMessageRead(document, widget.conversationId);
    }

    print('message -> ${document['content']}');

    if (document['idFrom'] == widget.loginId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Bubble(
                  color: Colors.blueGrey,
                  elevation: 0,
                  padding: const BubbleEdges.all(10.0),
                  nip: BubbleNip.rightTop,
                  child: Text(document['content'],
                      style: TextStyle(color: Colors.white))),
              width: 200)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                child: Bubble(
                    color: Colors.lightBlue[100],
                    elevation: 0,
                    padding: const BubbleEdges.all(10.0),
                    nip: BubbleNip.leftTop,
                    child: Text(document['content'],
                        style: TextStyle(color: Colors.black))),
                width: 200.0,
                margin: const EdgeInsets.only(left: 10.0),
              )
            ])
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  Widget buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: Database.getMessages(widget.conversationId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) =>
                  buildItem(index, snapshot.data!.docs[index]),
              itemCount: snapshot.data!.docs.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  Widget buildInput() {
    return Row(
      children: <Widget>[
        // Edit text
        Flexible(
          child: TextField(
            autofocus: true,
            controller: textEditingController,
            decoration: const InputDecoration.collapsed(
              hintText: 'Type your message...',
            ),
          ),
        ),
        IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (textEditingController.text.trim() == '') return;

              Database.sendMessage(
                  widget.conversationId,
                  widget.loginId,
                  widget.chatTo['id'],
                  textEditingController.text.trim(),
                  DateTime.now().millisecondsSinceEpoch.toString());

              textEditingController.clear();

// scroll to bottom
              listScrollController.animateTo(0.0,
                  duration: Duration(milliseconds: 300), curve: Curves.easeOut);
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTo['name']),
      ),
      body: Column(
        children: <Widget>[
          buildMessages(),
          buildInput(),
        ],
      ),
    );
  }
}
