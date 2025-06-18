import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Stream<User?> _authStateStream;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authStateStream = FirebaseAuth.instance.authStateChanges();
    _authSubscription = _authStateStream.listen((user) {
      if (user == null) {
        Future.microtask(() {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              final googleSignIn = GoogleSignIn();
              await googleSignIn.signOut();
              await googleSignIn.disconnect();
              // Navigasi otomatis akan dilakukan oleh listener
            },
          ),
        ],
      ),
      body: Center(
        child:
            user == null
                ? const Text('No user logged in')
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (user.photoURL != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoURL!),
                        radius: 40,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? '-',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
      ),
    );
  }
}
