import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './services/friends_service.dart';
import '../friends/friend_achievements_page.dart';

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
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.pushNamed(context, '/requests_page'),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, currentUserSnapshot) {
          if (!currentUserSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentData =
              currentUserSnapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> friends = currentData['friends'] ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs
                  .where((u) => u.id != currentUser.uid)
                  .toList();

              // 🔹 Filtramos amigos y no amigos
              final friendsList = users
                  .where((u) => friends.contains(u.id))
                  .toList(); // amigos
              final othersList = users
                  .where((u) => !friends.contains(u.id))
                  .toList(); // otros usuarios

              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Mis Amigos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Lista de amigos
                  if (friendsList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No tienes amigos todavía'),
                    )
                  else
                    ...friendsList.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FriendAchievementsPage(
                                  friendUid: doc.id,
                                  friendDisplayName:
                                      data['displayName'] ?? 'Jugador',
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: data['photoUrl'] != null
                                ? NetworkImage(data['photoUrl'])
                                : null,
                            child: data['photoUrl'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                        title: Text(data['displayName'] ?? 'Jugador'),
                        subtitle: Text(data['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/chat_page',
                              arguments: {
                                'friendId': doc.id,
                                'friendName': data['displayName'] ?? 'Jugador',
                              },
                            );
                          },
                        ),
                      );
                    }),

                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Otros Jugadores',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  //Lista de otros usuarios
                  ...othersList.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(data['displayName'] ?? 'Jugador'),
                      subtitle: Text(data['email'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await friendsService.sendFriendRequest(
                            currentUser.uid,
                            doc.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solicitud enviada ✅'),
                            ),
                          );
                        },
                        child: const Text('Agregar'),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
