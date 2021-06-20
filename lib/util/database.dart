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
/*
  static Future<void> addItem({
    required String title,
    required String description,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userUid).collection('items').doc();

    Map<String, dynamic> data = <String, dynamic>{
      "title": title,
      "description": description,
    };

    await documentReferencer
        .set(data)
        .whenComplete(() => print("Note item added to the database"))
        .catchError((e) => print(e));
  }

  static Future<void> updateItem({
    required String title,
    required String description,
    required String docId,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userUid).collection('items').doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "title": title,
      "description": description,
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Note item updated in the database"))
        .catchError((e) => print(e));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>?>> readItems() {
    CollectionReference notesItemCollection =
        _mainCollection.doc(userUid).collection('items');

    return notesItemCollection.snapshots()
        as Stream<QuerySnapshot<Map<String, dynamic>?>>;
  }

  static Stream<QuerySnapshot> readItemsOld() {
    CollectionReference notesItemCollection =
        _mainCollection.doc(userUid).collection('items');

    return notesItemCollection.snapshots();
  }

  static Future<void> deleteItem({
    required String docId,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userUid).collection('items').doc(docId);

    await documentReferencer
        .delete()
        .whenComplete(() => print('Note item deleted from the database'))
        .catchError((e) => print(e));
  }*/
}
