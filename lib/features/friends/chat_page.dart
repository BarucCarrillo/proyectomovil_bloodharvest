import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../friends/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String friendUid;
  final String? friendName;
  const ChatPage({super.key, required this.friendUid, this.friendName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;
  final _chatService = ChatService();
  final _controller = TextEditingController();
  String? chatId;
  String friendName = '';

  @override
  void initState() {
    super.initState();
    friendName = widget.friendName ?? 'Amigo';
    _initChat();
  }

  Future<void> _initChat() async {
    final uid = _auth.currentUser!.uid;
    chatId = await _chatService.createOrGetChat(uid, widget.friendUid);

    if (widget.friendName == null) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendUid)
          .get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        setState(() {
          friendName = data['displayName'] ?? friendName;
        });
      }
    }

    setState(() {});
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final fromUid = _auth.currentUser!.uid;
    await _chatService.SendMessage(chatId!, fromUid, text);
    _controller.clear();
  }

  //FORMATEO PARA LAS FECHAS
  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.Hm().format(dt);
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }

  //INTERFAZ DEL CHAT
  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myUid = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friendName, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.messageStream(chatId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data() as Map<String, dynamic>;
                    final bool isMe = msg['from'] == myUid;
                    final ts = msg['timestamp'] as Timestamp?;
                    final timeStr = _formatTimestamp(ts);

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.brown[300] : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _send,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
