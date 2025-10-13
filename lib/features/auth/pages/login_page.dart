//PANTALLA DE LOGIN

import 'package:flutter/material.dart';
import '../widgets/auth_form..dart';
import '../../../core/services/auth_service.dart';

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
      appBar: AppBar(title: Text(isLogin ? 'Iniciar Sesión' : 'Crear Cuenta')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthForm(isLogin: isLogin, onSubmit: _handleAuth),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin
                    ? '¿No tienes cuenta? Registrate'
                    : '¿Ya tienes cuenta? Inicia Sesión',
              ),
            ),
            if (isLogin)
              TextButton(
                onPressed: () async {
                  final email = await _askForEmail(context);
                  if (email != null && email.contains('@')) {
                    try {
                      await _authService.sendPasswordResetEmail(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('EMial de recuperación enviado'),
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
