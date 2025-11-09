import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyectomovil_bloodharvest/features/account/account_page.dart';
import 'package:proyectomovil_bloodharvest/features/achievements/achievements_page.dart';
import 'package:proyectomovil_bloodharvest/features/friends/friends_page.dart';
import 'package:proyectomovil_bloodharvest/features/friends/requests_page.dart';
import 'package:proyectomovil_bloodharvest/features/home/home_page.dart';
import 'package:proyectomovil_bloodharvest/features/friends/chat_page.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

//FUNCION PRINCIPAL PARA INICIAR LA APLICACION

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://ljaswixhpkowjenkkdse.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqYXN3aXhocGtvd2plbmtrZHNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2NzAxNjMsImV4cCI6MjA3ODI0NjE2M30.HGnJZac50LCPxnkCvQPa8vUkSpm04Utw616DVy0KRjw',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Harvest',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light, //Tema claro
        colorScheme: ColorScheme.light(
          primary: Colors.brown[700]!, // Color principal (AppBar, botones)
          secondary: Colors.brown[500]!, // Detalles secundarios
          surface: Colors.white, // Fondo principal claro
          onPrimary: Colors.white, // Texto en botones y AppBar
          onSurface: Colors.brown[900]!, // Texto en fondos claros
        ),

        //AppBar (barra superior)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5D4037), // Café oscuro
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),

        //BottomNavigationBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.brown[800],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
        ),

        //Botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        //Campos de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.brown[50],
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.brown[700]!),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: TextStyle(color: Colors.brown[800]),
        ),

        //SnackBars y otros overlays
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.brown[800],
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        //Fondo general
        scaffoldBackgroundColor: Colors.brown[50],
      ),

      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(),
        '/friends': (context) => const FriendsPage(),
        '/achievements': (context) => const AchievementsPage(),
        '/requests_page': (context) => const RequestsPage(),
        '/friends_achievements_page': (context) => RequestsPage(),
        '/account_page': (context) => EditProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat_page') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatPage(
              friendUid: args['friendId'],
              friendName: args['friendName'],
            ),
          );
        }
        return null;
      },
    );
  }
}
