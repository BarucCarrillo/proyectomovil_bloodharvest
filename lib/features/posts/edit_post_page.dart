import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/texts.dart';

class EditPostPage extends StatefulWidget {
  final String postId;
  final String title;
  final String content;
  final String imageUrl;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  File? newImageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        newImageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadImageToSupabase(File image) async {
    final supabase = Supabase.instance.client;

    try {
      final fileName =
          '${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('posts')
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from('posts').getPublicUrl(fileName);
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String updatedImageUrl = widget.imageUrl;

    if (newImageFile != null) {
      final url = await uploadImageToSupabase(newImageFile!);
      if (url != null) updatedImageUrl = url;
    }

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .update({
          "title": _titleController.text.trim(),
          "content": _contentController.text.trim(),
          "imageUrl": updatedImageUrl,
          "updatedAt": FieldValue.serverTimestamp(),
        });

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      appBar: AppBar(title: Text(Texts.t("editPost", isEnglish))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: newImageFile != null
                            ? Image.file(
                                newImageFile!,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : (widget.imageUrl.isNotEmpty
                                  ? Image.network(
                                      widget.imageUrl,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Container(
                                          height: 200,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.broken_image),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 200,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 30,
                                      ),
                                    )),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: Texts.t("title", isEnglish),
                      ),
                      validator: (value) => value!.isEmpty
                          ? Texts.t("fillAllFields", isEnglish)
                          : null,
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: Texts.t("content", isEnglish),
                      ),
                      maxLines: 5,
                      validator: (value) => value!.isEmpty
                          ? Texts.t("fillAllFields", isEnglish)
                          : null,
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: saveChanges,
                      child: Text(Texts.t("saveChanges", isEnglish)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
