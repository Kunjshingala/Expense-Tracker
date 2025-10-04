import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import '../../../utils/custom_icons.dart';
import '../manage_transaction/add_transaction/add_transaction_screen.dart';
import 'analysis/analysis_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'transactions/transactions_screen.dart';

class MainNavigationBloc {
  final BuildContext context;

  MainNavigationBloc({required this.context});

  PersistentTabController persistentTabController = PersistentTabController(initialIndex: 0);

  List<PersistentTabConfig> persistentTabList = [
    PersistentTabConfig(
      screen: const HomeScreen(),
      item: ItemConfig(
        icon: const Icon(CustomIcons.home_icons),
        inactiveIcon: const Icon(CustomIcons.home_icons),
        title: "Home",
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: averageScreenSize * 0.02,
        ),
        activeForegroundColor: violet100,
        inactiveForegroundColor: greyColor,
      ),
    ),
    if (showTransaction)
      PersistentTabConfig(
        screen: const TransactionsScreen(),
        item: ItemConfig(
          icon: const Icon(CustomIcons.transaction_icons),
          inactiveIcon: const Icon(CustomIcons.transaction_icons),
          title: "Transaction",
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: averageScreenSize * 0.02,
          ),
          activeForegroundColor: violet100,
          inactiveForegroundColor: greyColor,
        ),
      ),
    PersistentTabConfig(
      screen: const AddTransactionScreen(),
      item: ItemConfig(
        icon: const Icon(CustomIcons.add_icon),
        inactiveIcon: const Icon(CustomIcons.add_icon),
        iconSize: averageScreenSize * 0.03,
        activeForegroundColor: violet100,
        inactiveForegroundColor: white100,
      ),
    ),
    if (showAnalysis)
      PersistentTabConfig(
        screen: const AnalysisScreen(),
        item: ItemConfig(
          icon: const Icon(CustomIcons.pie_chart_icons),
          inactiveIcon: const Icon(CustomIcons.pie_chart_icons),
          title: "Analysis",
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: averageScreenSize * 0.02,
          ),
          activeForegroundColor: violet100,
          inactiveForegroundColor: greyColor,
        ),
      ),
    PersistentTabConfig(
      screen: const ProfileScreen(),
      item: ItemConfig(
        icon: const Icon(CustomIcons.user_icons),
        inactiveIcon: const Icon(CustomIcons.user_icons),
        title: "Profile",
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: averageScreenSize * 0.02,
        ),
        activeForegroundColor: violet100,
        inactiveForegroundColor: greyColor,
      ),
    ),
  ];

  void dispose() {
    persistentTabController.dispose();
  }
}
