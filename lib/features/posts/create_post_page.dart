import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  File? _imageFile;
  bool _loading = false;

  final supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seleccionar imagen
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // Subir publicación
  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser!;
      String? imageUrl;

      //Subir imagen a Supabase (si existe)
      if (_imageFile != null) {
        final filePath =
            "posts/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await supabase.storage
            .from("posts")
            .upload(
              filePath,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );

        imageUrl = supabase.storage.from("posts").getPublicUrl(filePath);
      }

      // Guardar en Firestore
      await _firestore.collection("posts").add({
        "title": _titleController.text.trim(),
        "content": _contentController.text.trim(),
        "imageUrl": imageUrl ?? "",
        "authorId": user.uid,
        "authorName": user.displayName ?? "Usuario",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Publicación creada")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al publicar: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear publicación")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Título",
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Contenido",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 12),

            // Imagen
            if (_imageFile != null) Image.file(_imageFile!, height: 200),

            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Seleccionar imagen"),
              onPressed: _pickImage,
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: _loading ? null : _submitPost,
              icon: const Icon(Icons.send),
              label: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Publicar"),
            ),
          ],
        ),
      ),
    );
  }
}
