import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //CREAR chatId A PARTIR DE LOS UIDS DE LOS USUARIOS
  String getChatId(String uidA, String uidB) {
    final list = [uidA, uidB]..sort();
    return 'chat_${list[0]}_${list[1]}';
  }

  Future<String> createOrGetChat(String uidA, String uidB) async {
    final chatId = getChatId(uidA, uidB);
    final chatRef = _db.collection('chats').doc(chatId);
    final snap = await chatRef.get();
    if (!snap.exists) {
      await chatRef.set({
        'users': [uidA, uidB],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Stream<QuerySnapshot> messageStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> SendMessage(String chatId, String fromUid, String text) async {
    final messagesRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages');
    final chatRef = _db.collection('chats').doc(chatId);

    final batch = _db.batch();

    final newWsgRef = messagesRef.doc();
    batch.set(newWsgRef, {
      'from': fromUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });

    batch.update(chatRef, {
      'lastMessage': text,
      'updateAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<DocumentSnapshot> chatMetaStream(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots();
  }
}
