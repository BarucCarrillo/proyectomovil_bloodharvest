//SERVICO DE INICIO DE SESION, REGISTRO, CERRAR SESION Y RECUPERAR CONTRASEÑA

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // VERIFICAR ESTADO DE AUTENTICACION

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  //INICIO DE SESION

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //REGISTRO
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //GUARDA USUARIO EN FIRESTORE Y CREA DOCUMENTO USERS
    final uid = credential.user!.uid;
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'friends': [],
      'request_received': [],
      'request_sent': [],
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    //ACTUALIZAR DISPLAYNAME
    await credential.user!.updateDisplayName(displayName);

    return credential;
  }

  //CERRRAR SESION
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //RECUPERAR CONTRASEÑA
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
