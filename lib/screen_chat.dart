import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScreenChat extends StatefulWidget {
  final String loginId, conversationId;
  final User chatTo;

  const ScreenChat(
      {Key? key,
      required this.loginId,
      required this.conversationId,
      required this.chatTo})
      : super(key: key);

  @override
  _ScreenChatState createState() => _ScreenChatState();
}

class _ScreenChatState extends State<ScreenChat> {
  Widget buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('chat_messages')
            .document(convoID)
            .collection(convoID)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildInput() {
    return Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              // Edit text
              Flexible(
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        autofocus: true,
                        maxLines: 5,
                        controller: textEditingController,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type your message...',
                        ),
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.send, size: 25),
                  onPressed: () => onSendMessage(textEditingController.text),
                ),
              ),
            ],
          ),
        ),
        width: double.infinity,
        height: 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildMessages(),
        buildInput(),
      ],
    );
  }
}
