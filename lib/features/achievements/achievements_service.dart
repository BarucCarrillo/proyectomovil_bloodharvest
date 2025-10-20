import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //OBTENER LOS LOGROS DEL JUGADOR
  Stream<QuerySnapshot> getUserAchievements() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .orderBy('date', descending: true)
        .snapshots();
  }

  //CREAR UN NUEVO LOGRO
  Future<void> addAchievements(String title, String description) async {
    final uid = _auth.currentUser?.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .add({
          'title': title,
          'description': description,
          'date': DateTime.now(),
        });
  }

  //ELIMINAR UN LOGRO MEDIANTE ID
  Future<void> deleteAchievement(String docId) async {
    final uid = _auth.currentUser?.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .doc(docId)
        .delete();
  }
}
