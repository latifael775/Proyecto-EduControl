import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/preceptor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activa el modo offline
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const AppEscolar());
}

class AppEscolar extends StatelessWidget {
  const AppEscolar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Este widget decide qué pantalla mostrar según si hay sesión activa
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escucha si hay un usuario logueado
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Mientras verifica, muestra un loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay usuario logueado → navega según su rol
        if (snapshot.hasData && snapshot.data != null) {
          return const RolRouter();
        }

        // Si no hay usuario → muestra el login
        return const LoginScreen();
      },
    );
  }
}

// Este widget obtiene el rol y navega a la pantalla correcta
class RolRouter extends StatelessWidget {
  const RolRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const LoginScreen();
        }

        final rol = snapshot.data!.get('rol') as String?;

        switch (rol) {
          case 'admin':
            return const AdminScreen();
          case 'preceptor':
            return const PreceptorScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}