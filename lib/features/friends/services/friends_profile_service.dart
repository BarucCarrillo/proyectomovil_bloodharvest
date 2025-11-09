import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getFriendAchievements(
    String userUid,
  ) async {
    try {
      //DOCUMENTO DEL USUARIO ACTUAL
      final userDoc = await _firestore.collection('users').doc(userUid).get();

      if (!userDoc.exists) return [];

      //OBTENER LISTA DE AMIGOS
      final data = userDoc.data() as Map<String, dynamic>;
      List<dynamic> friendsUids = data['friends'] ?? [];

      //LISTA PARA GUARDAR LOGROS DEL AMIGO
      List<Map<String, dynamic>> friendAchievements = [];

      //RECOORER LISTA DE AMIGOS
      for (var friendUid in friendsUids) {
        final friendDoc = await _firestore
            .collection('users')
            .doc(friendUid)
            .get();

        if (friendDoc.exists) {
          final friendData = friendDoc.data() as Map<String, dynamic>;
          final friendName = friendData['displayName'] ?? 'Jugador';
          final achievements = List<Map<String, dynamic>>.from(
            friendData['achievements'] ?? [],
          );

          //Agregar la información a la lista final
          friendAchievements.add({
            'uid': friendUid,
            'name': friendName,
            'achievements': achievements,
          });
        }
      }

      return friendAchievements;
    } catch (e) {
      print('Error al obtener los logros de amigos: $e');
      return [];
    }
  }
}
