// WRAPPER QUE DECIDE SI MOSTRAR LOGIN O HOME SEGUN EL ESTADO ACTUAL DE AUTENTICACION

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './features/auth/pages/login_page.dart';
import './features/home/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //CARGANDO
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //USUARIO LOGEADO DIRIGIDO A HOME
        if (snapshot.hasData) {
          return const HomePage();
        }

        //NO LOGEADO REGRESA A LOGIN
        return const LoginPage();
      },
    );
  }
}
