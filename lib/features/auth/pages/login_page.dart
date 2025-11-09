//PANTALLA DE LOGIN Y REGISTRO

import 'package:flutter/material.dart';
import '../widgets/auth_form..dart';
import '../../../core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final AuthService _authService = AuthService();

  void _handleAuth(String email, String password, [String? displayName]) async {
    try {
      if (isLogin) {
        await _authService.signInWithEmail(email, password);

        final user = _authService.currentUser;
        if (user != null) {
          final firestore = FirebaseFirestore.instance;
          final userDoc = firestore.collection('users').doc(user.uid);

          final snapshot = await userDoc.get();
          if (snapshot.exists) {
            final firestoreEmail = snapshot['email'];
            if (firestoreEmail != user.email) {
              await userDoc.update({'email': user.email});
            }
          }
        }
      } else {
        await _authService.registerWithEmail(
          email,
          password,
          displayName ?? 'JUgador',
        );
      }
    } on Exception catch (e) {
      final message = (e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 180,
        title: Text(
          'Bienvenido a la\n comunidad de\n Blood Harvest\n\n ${isLogin ? 'Iniciar Sesión' : 'Crear Cuenta'}',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthForm(isLogin: isLogin, onSubmit: _handleAuth),
            SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin
                    ? '¿No tienes cuenta? Registrate'
                    : '¿Ya tienes cuenta? Inicia Sesión',
              ),
            ),
            if (isLogin) SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                final email = await _askForEmail(context);
                if (email != null && email.contains('@')) {
                  try {
                    await _authService.sendPasswordResetEmail(email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email de recuperación enviado'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: const Text('Olvidé mi contraseña'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _askForEmail(BuildContext ctx) {
    final ctrl = TextEditingController();
    return showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Tu Correo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(ctrl.text.trim()),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
