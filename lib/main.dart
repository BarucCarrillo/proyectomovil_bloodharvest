import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyectomovil_bloodharvest/features/achievements/achievements_page.dart';
import 'package:proyectomovil_bloodharvest/features/friends/friends_page.dart';
import 'package:proyectomovil_bloodharvest/features/friends/requests_page.dart';
import 'package:proyectomovil_bloodharvest/features/home/home_page.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

//FUNCION PRINCIPAL PARA INICIAR LA APLICACION

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Harvest',
      theme: ThemeData.fallback(),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(),
        '/friends': (context) => const FriendsPage(),
        '/achievements': (context) => AchievementsPage(),
        '/requests_page': (context) => RequestsPage(),
      },
    );
  }
}
