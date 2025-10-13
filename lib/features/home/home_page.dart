import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

//VIATA DE PRUEBA PARA MOSTRAR DATOS BASICOS DEL USUARIO LOGEADO Y BOTON DE CERRAR SESION

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Jugador';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService()
                  .signOut(); //AUTH WRAPPER CAMBIA Y CIERRA SESIÓN
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, $displayName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Correo: $email'),
            const SizedBox(height: 20),
            //ELEMENTOS
            ElevatedButton(onPressed: () {}, child: const Text('PROXIMAMENTE')),
          ],
        ),
      ),
    );
  }
}
