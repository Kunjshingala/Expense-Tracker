import 'package:expense_tracker/ui/screens/splash/splash_screen.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'utils/dimens.dart';

late AppLocalizations languages;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    averageScreenSize = (screenWidth + screenHeight) / 2;

    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? '',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: violet100Color),
        useMaterial3: true,
      ),

      // locale: selectedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          languages = AppLocalizations.of(context)!;
          return const SplashScreen();
        },
      ),
      // home: const MainNavigationScreen(),
      // home: const ProfileScreen(),
      // home: const AddTransactionScreen(),

      /// update screen
      // home: UpdateTransactionScreen(
      //   amount: '100',
      //   transactionType: TransactionType.Expense,
      //   selectedCategory: TransactionCategoryModal(
      //     icon: const CategoryIcon(
      //       iconData: CustomIcons.lottery_icon,
      //       label: 'Lottery',
      //     ),
      //     label: 'Lottery',
      //     id: 1,
      //   ),
      //   transactionMode: TransactionMode.Cash,
      //   date: '22 April 2024',
      //   address: 'rajkot',
      //   url:
      //       'https://firebasestorage.googleapis.com/v0/b/expense-tracker-a64ac.appspot.com/o/users%2FufVKtHLmGRbX707WtO1QWlLEDR03%2FufVKtHLmGRbX707WtO1QWlLEDR03-1713792823748108.jpg?alt=media&token=2d5d5c22-d619-4bb0-ab8f-26370c34f907',
      // ),
    );
  }
}
