import 'package:cloud_firestore/cloud_firestore.dart';

//SERVICIO PARA REALIZAR LAS OPERACIONES DE AMIGOS
class FriendsService {
  final _db = FirebaseFirestore.instance;

  //AGREGAR AMIGO
  Future<void> sendFriendRequest(
    String currentUserId,
    String targetUserId,
  ) async {
    final currentRef = _db.collection('users').doc(currentUserId);
    final targetRef = _db.collection('users').doc(targetUserId);

    await _db.runTransaction((transaction) async {
      final targetSnap = await transaction.get(targetRef);
      final currentSnap = await transaction.get(currentRef);

      List<String> sent = List<String>.from(currentSnap['request_sent'] ?? []);
      List<String> received = List<String>.from(targetSnap['request_received']);

      //VALIDACIÓN DE QUE LOS USUARIOS NO SON AMIGOS
      if (!sent.contains(targetUserId) && !received.contains(currentUserId)) {
        sent.add(targetUserId);
        received.add(currentUserId);

        transaction.update(currentRef, {'request_sent': sent});
        transaction.update(targetRef, {'request_received': received});
      }
    });
  }

  //SERVICIO PARA ACEPTAR LA SOLICITUD
  Future<void> acceptFriendRequest(
    String currentUserId,
    String requesterId,
  ) async {
    final currentRef = _db.collection('users').doc(currentUserId);
    final requesterRef = _db.collection('users').doc(requesterId);

    await _db.runTransaction((transaction) async {
      final currentSnap = await transaction.get(currentRef);
      final requesterSnap = await transaction.get(requesterRef);

      List<String> friendsCurrent = List<String>.from(
        currentSnap['friends'] ?? [],
      );
      List<String> friendsRequester = List<String>.from(
        requesterSnap['friends'] ?? [],
      );
      List<String> received = List<String>.from(
        currentSnap['request_received'] ?? [],
      );
      List<String> sent = List<String>.from(currentSnap['request_sent'] ?? []);

      friendsCurrent.add(requesterId);
      friendsRequester.add(currentUserId);
      received.remove(requesterId);
      sent.remove(currentUserId);

      transaction.update(currentRef, {
        'friends': friendsCurrent,
        'request_received': received,
      });

      transaction.update(requesterRef, {
        'friends': friendsRequester,
        'request_sent': sent,
      });
    });
  }

  Future<void> rejectFriendRequest(
    String currentUserId,
    String requesterId,
  ) async {
    final currentRef = _db.collection('users').doc(currentUserId);
    final requestRef = _db.collection('users').doc(requesterId);

    await _db.runTransaction((transaction) async {
      final currentSnap = await transaction.get(currentRef);
      final requesterSnap = await transaction.get(requestRef);

      List<String> received = List<String>.from(
        currentSnap['request_received'] ?? [],
      );
      List<String> sent = List<String>.from(
        requesterSnap['request_sent'] ?? [],
      );

      received.remove(requesterId);
      sent.remove(currentUserId);

      transaction.update(currentRef, {'request_received': received});
      transaction.update(requestRef, {'request_sent': sent});
    });
  }
}
