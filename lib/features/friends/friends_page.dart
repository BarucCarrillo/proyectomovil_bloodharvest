import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './services/friends_service.dart';
import '../friends/friend_achievements_page.dart';
import '../../utils/texts.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

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

              // Filtrar amigos y otros jugadores
              final friendsList = users
                  .where((u) => friends.contains(u.id))
                  .toList();

              final othersList = users
                  .where((u) => !friends.contains(u.id))
                  .toList();

              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      Texts.t("myFriends", isEnglish),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Lista de amigos
                  if (friendsList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(Texts.t("noFriends", isEnglish)),
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
                                      data['displayName'] ??
                                      Texts.t("player", isEnglish),
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
                        title: Text(
                          data['displayName'] ?? Texts.t("player", isEnglish),
                        ),
                        subtitle: Text(data['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/chat_page',
                              arguments: {
                                'friendId': doc.id,
                                'friendName':
                                    data['displayName'] ??
                                    Texts.t("player", isEnglish),
                              },
                            );
                          },
                        ),
                      );
                    }),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      Texts.t("otherPlayers", isEnglish),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Lista de otros jugadores
                  ...othersList.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(
                        data['displayName'] ?? Texts.t("player", isEnglish),
                      ),
                      subtitle: Text(data['email'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await friendsService.sendFriendRequest(
                            currentUser.uid,
                            doc.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(Texts.t("requestSent", isEnglish)),
                            ),
                          );
                        },
                        child: Text(Texts.t("add", isEnglish)),
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
