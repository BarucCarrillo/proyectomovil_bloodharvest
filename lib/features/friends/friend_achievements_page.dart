import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FriendAchievementsPage extends StatelessWidget {
  final String friendUid;
  final String friendDisplayName;

  const FriendAchievementsPage({
    super.key,
    required this.friendUid,
    required this.friendDisplayName,
  });

  Future<List<Map<String, dynamic>>> _getAchievements() async {
    try {
      final achievementsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .collection('achievements')
          .get();

      return achievementsSnapshot.docs.map((doc) {
        return {
          'title': doc['title'] ?? 'Sin título',
          'description': doc['description'] ?? '',
          'date': doc['date'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error al obtener logros: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logros de $friendDisplayName')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final achievements = snapshot.data ?? [];
          if (achievements.isEmpty) {
            return const Center(child: Text('Este amigo no tiene logros aún.'));
          }

          return ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              //FORMATEO DE FECHAS
              final timestamp = achievement['date'] as Timestamp;
              final date = timestamp.toDate();
              final formattedDate = DateFormat('dd/MM/yyyy').format(date);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.amber),
                  title: Text(achievement['title'] ?? 'Logro'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (achievement['description'] != null &&
                          achievement['description'].toString().isNotEmpty)
                        Text(achievement['description']),
                      if (achievement['date'] != null)
                        Text(
                          'Fecha: $formattedDate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
