import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/texts.dart';

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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submitPost() async {
    final isEnglish = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).isEnglish;

    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Texts.t("fillAllFields", isEnglish))),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser!;
      String? imageUrl;

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

      await _firestore.collection("posts").add({
        "title": _titleController.text.trim(),
        "content": _contentController.text.trim(),
        "imageUrl": imageUrl ?? "",
        "authorId": user.uid,
        "authorName": user.displayName ?? "User",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Texts.t("postCreated", isEnglish))),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${Texts.t("postError", isEnglish)} $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      appBar: AppBar(title: Text(Texts.t("createPost", isEnglish))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: Texts.t("title", isEnglish),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: Texts.t("content", isEnglish),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 12),

            if (_imageFile != null) Image.file(_imageFile!, height: 200),

            TextButton.icon(
              icon: const Icon(Icons.image),
              label: Text(Texts.t("selectImage", isEnglish)),
              onPressed: _pickImage,
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: _loading ? null : _submitPost,
              icon: const Icon(Icons.send),
              label: _loading
                  ? const CircularProgressIndicator()
                  : Text(Texts.t("publish", isEnglish)),
            ),
          ],
        ),
      ),
    );
  }
}
