import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyectomovil_bloodharvest/core/services/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/language_provider.dart';
import '../../utils/texts.dart';
import 'package:provider/provider.dart';

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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() => _uploadingImage = true);

    try {
      final user = _auth.currentUser!;
      final filePath = 'profile_images/${user.uid}.jpeg';

      await supabase.storage
          .from('profile_images')
          .upload(
            filePath,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          supabase.storage.from('profile_images').getPublicUrl(filePath) +
          '?v=${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': publicUrl,
      });

      await user.updatePhotoURL(publicUrl);

      setState(() {
        _photoUrl = publicUrl;
        _uploadingImage = false;
        _imageFile = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Texts.t("saveImage", true))));
    } catch (e) {
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
      });

      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Email verification sent")));
      }

      if (newPassword.isNotEmpty && newPassword.length >= 6) {
        await user.updatePassword(newPassword);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isEng = lang.isEnglish;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(Texts.t("editProfile", isEng))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
                label: Text(
                  _uploadingImage
                      ? Texts.t("uploading", isEng)
                      : Texts.t("saveImage", isEng),
                ),
              ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: Texts.t("name", isEng),
                prefixIcon: const Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: Texts.t("email", isEng),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: Texts.t("newPassword", isEng),
                prefixIcon: const Icon(Icons.lock),
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
              label: Text(Texts.t("logout", isEng)),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => lang.toggleLanguage(),
              child: Text(Texts.t("changeLanguage", isEng)),
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
                  : Text(Texts.t("saveChanges", isEng)),
            ),
          ],
        ),
      ),
    );
  }
}
