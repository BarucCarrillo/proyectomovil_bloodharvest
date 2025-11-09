import 'package:flutter/material.dart';
import 'package:proyectomovil_bloodharvest/features/account/account_page.dart';
import '../../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../achievements/achievements_page.dart';
import '../friends/friends_page.dart';
import 'pages/news_page.dart';

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
    NewsPage(),
    EditProfilePage(),
  ];

  final List<String> _titles = const [
    'Logros',
    'Amigos',
    'Noticias',
    'Configuración',
  ];

  //Cargar nombre del usuario desde Firestore
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

  // CARGAR NOMBRE
  @override
  void initState() {
    super.initState();
    _loadUserDisplayName();
  }

  //CAMBIAR PÁGINA Y REFRESCAR
  void _onItemTapped(int index) async {
    if (index == 3) {
      // SI SE ENTRA A CONFIGURACIÓN
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfilePage()),
      );
      await _loadUserDisplayName(); // REFRESCAR EL NOMBRE
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_titles[_selectedIndex]} de $displayName')),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Logros',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Amigos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
