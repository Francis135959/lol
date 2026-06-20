import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore firestore;

  FirestoreService(this.firestore);

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  WriteBatch batch() {
    return firestore.batch();
  }
}