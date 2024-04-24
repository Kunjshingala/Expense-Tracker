import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/colors.dart';
import 'splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashBloc splashBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashBloc = SplashBloc();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    splashBloc.decideFlow(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: violet100Color.withOpacity(0.80),
          ),
          Positioned(
            top: screenHeight * 0.39,
            left: screenWidth * 0.19,
            child: Image.asset(
              'assets/images/splash_image.png',
              color: yellow100Color,
              width: averageScreenSize * 0.3,
              height: averageScreenSize * 0.3,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              'Montra',
              style: GoogleFonts.inter(
                color: light100Color,
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
