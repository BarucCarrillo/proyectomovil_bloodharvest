import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = ['Carlos', 'Ana', 'Miguel'];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(friends[index]),
            subtitle: Text(friends[index]),
            trailing: const Icon(Icons.chat_bubble_outline_outlined),
          ),
        );
      },
    );
  }
}
