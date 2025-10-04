import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../../utils/colors.dart';
import 'main_navigation_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late MainNavigationBloc mainNavigationBloc;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          /// Status Bar
          statusBarColor: white100,
          // IOS
          statusBarBrightness: Brightness.dark,
          // Android
          statusBarIconBrightness: Brightness.light,

          /// Navigation Bar
          systemNavigationBarColor: white100,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    mainNavigationBloc = MainNavigationBloc(context: context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    mainNavigationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        controller: mainNavigationBloc.persistentTabController,
        tabs: mainNavigationBloc.persistentTabList,
        navBarBuilder: (navBarConfig) {
          return Style13BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: const NavBarDecoration(),
          );
        },
        screenTransitionAnimation: const ScreenTransitionAnimation(curve: Curves.bounceInOut),
        handleAndroidBackButtonPress: true,
      ),
    );
  }
}
