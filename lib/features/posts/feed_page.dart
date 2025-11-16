import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_post_page.dart';
import 'edit_post_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final supabase = Supabase.instance.client;

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 400 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async => setState(() {});

  Future<void> _scrollToTop() async {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return "";
    final date = ts.toDate();
    return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
  }

  // ELIMINAR POST (Firestore + Supabase)
  Future<void> _deletePost(DocumentSnapshot post) async {
    final data = post.data() as Map<String, dynamic>;
    final imageUrl = data["imageUrl"];

    try {
      //eliminar imagen del storage si existe
      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        final path = imageUrl.split("/public/").last;
        await supabase.storage.from("posts").remove([path]);
      }

      // eliminar documento
      await post.reference.delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Publicación eliminada")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al eliminar: $e")));
    }
  }

  //Menú de opciones para edición/eliminación
  Widget _buildPostMenu(Map<String, dynamic> data, DocumentSnapshot post) {
    final uid = _auth.currentUser!.uid;

    if (data["authorId"] != uid) {
      return const SizedBox();
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == "edit") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPostPage(
                postId: post.id,
                title: data["title"] ?? "",
                content: data["content"] ?? "",
                imageUrl: data["imageUrl"] ?? "",
              ),
            ),
          );
        } else if (value == "delete") {
          _deletePost(post);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: "edit",
          child: Row(
            children: [Icon(Icons.edit), SizedBox(width: 8), Text("Editar")],
          ),
        ),
        const PopupMenuItem(
          value: "delete",
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text("Eliminar"),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Publicaciones")),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("posts")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No hay publicaciones aún."));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final data = post.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen
                      if (data["imageUrl"] != null &&
                          data["imageUrl"].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            data["imageUrl"],
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data["title"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                //MENÚ EDITAR / ELIMINAR
                                _buildPostMenu(data, post),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(Icons.person, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  data["authorName"] ?? "Usuario",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(data["createdAt"]),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Text(
                              data["content"] ?? "",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      // Botones flotantes
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showBackToTop)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                heroTag: "backToTop",
                onPressed: _scrollToTop,
                backgroundColor: Colors.brown.shade400,
                child: const Icon(Icons.arrow_upward),
              ),
            ),

          FloatingActionButton(
            heroTag: "createPost",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
