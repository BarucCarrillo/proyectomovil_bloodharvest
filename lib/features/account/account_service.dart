import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  //OBTENER DATOS
  Future<Map<String, dynamic>?> getCurretnUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  //ACTUALIZAR PERFIL
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update(data);
  }
}
