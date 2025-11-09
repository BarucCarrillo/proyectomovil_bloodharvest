import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyectomovil_bloodharvest/core/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        _nameController.text = doc.data()?['displayName'] ?? '';
        _emailController.text = user.email ?? '';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _updating = true);

    try {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text.trim();

      //Actualizar nombre en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
      });

      //Actualizar email en Firebase Auth (si cambió)
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se envió un correo de verificación al nuevo email.'),
          ),
        );
      }

      //Actualizar contraseña (solo si ingresó una nueva)
      if (newPassword.isNotEmpty && newPassword.length >= 6) {
        await user.updatePassword(newPassword);
      }

      //Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito ✅')),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Error al actualizar el perfil.';
      if (e.code == 'requires-recent-login') {
        message =
            'Debes iniciar sesión nuevamente para cambiar correo o contraseña.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ocurrió un error: $e')));
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña (opcional)',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _updating ? null : _updateProfile,
              icon: const Icon(Icons.save),
              label: _updating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
