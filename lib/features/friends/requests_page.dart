import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './services/friends_service.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = FriendsService();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de Amistad')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final received = List<String>.from(data['request_received'] ?? []);

          if (received.isEmpty) {
            return const Center(
              child: Text('No tienes solicitudes pendientes.'),
            );
          }

          return ListView.builder(
            itemCount: received.length,
            itemBuilder: (context, index) {
              final requesterId = received[index];

              if (requesterId == null || requesterId.isEmpty) {
                return const ListTile(
                  title: Text('Solicitud inválida'),
                  subtitle: Text('El ID del usuario no es válido.'),
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(requesterId)
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final requester = snap.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(requester['displayName'] ?? []),
                    subtitle: Text(requester['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await service.acceptFriendRequest(
                              user.uid,
                              requesterId,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await service.rejectFriendRequest(
                              user.uid,
                              requesterId,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
