import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _messagesCollection =
    _firestore.collection('chat_msg');
final CollectionReference _usersCollection =
    _firestore.collection('chat_users');

class Database {
  // static String? userUid;

  static Future<void> addUser(User newUser) async {
    Map<String, dynamic> data = <String, dynamic>{
      'id': newUser.uid,
      'name': newUser.displayName,
      'email': newUser.email,
    };

    await _usersCollection.doc(newUser.uid).set(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String conversationId) {
    return _messagesCollection
        .doc(conversationId)
        .collection(conversationId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  static void sendMessage(
    String convoID,
    String id,
    String pid,
    String content,
    String timestamp,
  ) {
    final DocumentReference convoDoc = _messagesCollection.doc(convoID);

    convoDoc.set(<String, dynamic>{
      'lastMessage': <String, dynamic>{
        'idFrom': id,
        'idTo': pid,
        'timestamp': timestamp,
        'content': content,
        'read': false
      },
      'users': <String>[id, pid]
    }).then((dynamic success) {
      final DocumentReference messageDoc =
          _messagesCollection.doc(convoID).collection(convoID).doc(timestamp);

      _firestore.runTransaction((Transaction transaction) async {
        transaction.set(
          messageDoc,
          <String, dynamic>{
            'idFrom': id,
            'idTo': pid,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'read': false
          },
        );
      });
    });
  }
}
