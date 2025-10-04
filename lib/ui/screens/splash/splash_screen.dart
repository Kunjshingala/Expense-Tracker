import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimens.dart';
import 'splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashBloc splashBloc;

  @override
  void didChangeDependencies() {
    splashBloc = SplashBloc(context: context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(

            /// Status Bar
            // statusBarColor: violet80,
            // IOS
            // statusBarBrightness: Brightness.dark,
            // Android
            // statusBarIconBrightness: Brightness.light,

            /// Navigation Bar
            // systemNavigationBarColor: violet80,
            // systemNavigationBarIconBrightness: Brightness.light,
            ),
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: violet80,
          ),
          Positioned(
            top: screenHeight * 0.39,
            left: screenWidth * 0.19,
            child: Image.asset(
              'assets/images/splash_image.png',
              color: yellow100,
              width: averageScreenSize * 0.3,
              height: averageScreenSize * 0.3,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              languages.appName,
              textAlign: TextAlign.start,
              style: GoogleFonts.inter(
                color: white100,
                fontSize: averageScreenSize * 0.08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
