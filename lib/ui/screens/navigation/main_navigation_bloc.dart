import 'package:expense_tracker/ui/screens/navigation/home/home_screen.dart';
import 'package:expense_tracker/ui/screens/navigation/transactions/transactions_screen.dart';
import 'package:expense_tracker/utils/custom_icons.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../../utils/colors.dart';
import 'analysis/analysis_screen.dart';
import 'profile/profile_screen.dart';

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
        activeForegroundColor: violet100Color,
        inactiveForegroundColor: greyColor,
      ),
    ),
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
        activeForegroundColor: violet100Color,
        inactiveForegroundColor: greyColor,
      ),
    ),
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
        activeForegroundColor: violet100Color,
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
        activeForegroundColor: violet100Color,
        inactiveForegroundColor: greyColor,
      ),
    ),
  ];

  void dispose() {
    persistentTabController.dispose();
  }
}
