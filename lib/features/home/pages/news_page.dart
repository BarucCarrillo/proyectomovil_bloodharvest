import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {
        'title': 'Evento especial disponible',
        'desc': 'Paarticipa para ganar recompensas exclusivas.',
      },
      {
        'title': 'Actualización 1.2',
        'desc': 'Se añadieron nuevo niveles y mejoras',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: news.length,
      itemBuilder: (context, index) {
        final item = news[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              item['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item['desc']!),
          ),
        );
      },
    );
  }
}
