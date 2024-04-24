import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../splash/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                }
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text('Profile'),
      ),
    );
  }
}
