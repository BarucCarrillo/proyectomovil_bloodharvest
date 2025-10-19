import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievements_service.dart';
import 'add_achievement_dialog.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementsService = AchievementsService();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: achievementsService.getUserAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no tienes logros.\n¡Agrega tu primer logro!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final achievements = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final data = achievements[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(data['title']),
                  subtitle: Text(data['description']),
                  trailing: IconButton(
                    onPressed: () =>
                        achievementsService.deleteAchievement(data.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),

      //BOTON PARA AGREGAR LOGROS
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[300],
        onPressed: () {
          showDialog(context: context, builder: (_) => AddAchievementDialog());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
