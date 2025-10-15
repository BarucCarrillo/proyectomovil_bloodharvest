import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {
        'title': 'Primer nivel completado',
        'desc': 'Has superado el primer reto',
      },
      {'title': 'Coleccionista', 'desc': 'Has reunido 100 monedas'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final item = achievements[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(item['title']!),
            subtitle: Text(item['desc']!),
          ),
        );
      },
    );
  }
}
