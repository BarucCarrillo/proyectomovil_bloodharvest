import 'package:flutter/material.dart';
import 'package:proyectomovil_bloodharvest/features/account/account_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../achievements/achievements_page.dart';
import '../friends/friends_page.dart';
import '../posts/feed_page.dart';
import '../inicio/inicio_page.dart';
import '../../utils/texts.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String displayName = 'Jugador';

  final List<Widget> _pages = const [
    AchievementsPage(),
    FriendsPage(),
    InicioPage(),
    FeedPage(),
    EditProfilePage(),
  ];

  // Lista de claves para Texts.t()
  final List<String> _titleKeys = const [
    "achievements",
    "friends",
    "home",
    "community",
    "settings",
  ];

  // Cargar nombre del usuario desde Firestore
  Future<void> _loadUserDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        displayName = doc.data()?['displayName'] ?? 'Jugador';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserDisplayName();
  }

  // Cambiar página y refrescar nombre si entran a configuración
  void _onItemTapped(int index) async {
    if (index == 4) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfilePage()),
      );
      await _loadUserDisplayName();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${Texts.t(_titleKeys[_selectedIndex], isEnglish)} "
          "${Texts.t('of', isEnglish)} "
          "$displayName",
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: Texts.t("achievements", isEnglish),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_add_rounded),
            label: Texts.t("friends", isEnglish),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: Texts.t("home", isEnglish),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: Texts.t("community", isEnglish),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_box),
            label: Texts.t("settings", isEnglish),
          ),
        ],
      ),
    );
  }
}
