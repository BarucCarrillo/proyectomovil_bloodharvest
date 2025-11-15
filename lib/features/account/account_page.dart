import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyectomovil_bloodharvest/core/services/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _imageFile;
  bool _loading = true;
  bool _updating = false;
  bool _uploadingImage = false;

  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar los datos actuales del usuario
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        _nameController.text = doc.data()?['displayName'] ?? '';
        _emailController.text = user.email ?? '';
        _photoUrl = doc.data()?['photoUrl'] ?? user.photoURL;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  //Seleccionar imagen de galería
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  //Subir imagen a Firebase Storage y actualizar Firestore/Auth
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() => _uploadingImage = true);

    try {
      final user = _auth.currentUser!;
      final filePath = 'profile_images/${user.uid}.jpeg';

      //Subir imagen a Supabase Storage
      await supabase.storage
          .from('profile_images')
          .upload(
            filePath,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      //Obtener URL pública
      final publicUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(filePath);

      //Actualizar Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': publicUrl,
      });

      //Actualizar en Firebase Auth
      await user.updatePhotoURL(publicUrl);

      setState(() {
        _photoUrl = publicUrl;
        _uploadingImage = false;
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (e) {
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
    }
  }

  // Actualizar nombre, correo y contraseña
  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _updating = true);

    try {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text.trim();

      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
      });

      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se envió un correo de verificación al nuevo email.'),
          ),
        );
      }

      if (newPassword.isNotEmpty && newPassword.length >= 6) {
        await user.updatePassword(newPassword);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito ')),
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
            // Imagen de perfil
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_photoUrl != null
                                  ? NetworkImage(_photoUrl!)
                                  : const AssetImage(
                                      'assets/default_avatar.png',
                                    ))
                              as ImageProvider,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.brown),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_imageFile != null)
              ElevatedButton.icon(
                onPressed: _uploadingImage ? null : _uploadProfileImage,
                icon: const Icon(Icons.upload),
                label: _uploadingImage
                    ? const Text('Subiendo...')
                    : const Text('Guardar Imagen'),
              ),

            const SizedBox(height: 24),
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
