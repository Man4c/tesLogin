import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';
import 'dart:async';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user == null)
            const Text('No user logged in')
          else ...[
            Center(
              child: Column(
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
                  Text(user.email ?? '-', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Video Pembelajaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final width = MediaQuery.of(context).size.width * 0.95;
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(8),
                      child: Center(
                        child: Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: YoutubePlayer(
                              controller: YoutubePlayerController(
                                initialVideoId: 'HyqU3hyCSnw',
                                flags: const YoutubePlayerFlags(
                                  autoPlay: true,
                                  mute: false,
                                ),
                              ),
                              showVideoProgressIndicator: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      YoutubePlayer.getThumbnail(videoId: 'HyqU3hyCSnw'),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 64,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
