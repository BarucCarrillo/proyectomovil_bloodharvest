import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './services/friends_service.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final friendsService = FriendsService();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.pushNamed(context, '/requests_page'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .where((u) => u.id != currentUser.uid)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final targetId = users[index].id;

              return ListTile(
                title: Text(data['displayName'] ?? 'Usuario'),
                subtitle: Text(data['email']),
                trailing: IconButton(
                  icon: Icon(Icons.person_add_alt_1),
                  onPressed: () async {
                    await friendsService.sendFriendRequest(
                      currentUser.uid,
                      targetId,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solicitud enviada')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
