import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addData(String collection, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).add(data);
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  Future<void> deleteData(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Stream<QuerySnapshot> getData(String collection) {
    return _db.collection(collection).snapshots();
  }
}