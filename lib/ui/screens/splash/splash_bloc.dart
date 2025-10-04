import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../intro/intro_screen.dart';
import '../main_home/main_navigation_screen.dart';

class SplashBloc {
  final BuildContext context;

  SplashBloc({required this.context}) {
    decideFlow();
  }

  void decideFlow() {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      debugPrint('decideFlow()---------------------------------->null');
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IntroScreen()));
      });
    } else {
      debugPrint('decideFlow()---------------------------------->!null');
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
      });
    }
  }
}
