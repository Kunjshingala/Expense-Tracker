import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimens.dart';
import '../../common_view/common_button.dart';
import '../authentication/sign_in/login/login_screen.dart';
import '../authentication/sign_up/sign_up_screen.dart';
import 'intro_bloc.dart';
import '../../../utils/route.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late IntroBloc introBloc;

  @override
  void didChangeDependencies() {
    introBloc = IntroBloc();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: white100,
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.175,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        initialPage: introBloc.pageIndexSubject.value,
                        height: screenHeight * 0.55,
                        viewportFraction: 1,
                        autoPlay: false,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          introBloc.pageIndexSubject.sink.add(index);
                        },
                      ),
                      items: [
                        IntroPage(
                          image: 'assets/images/intro_1.png',
                          text1: languages.onBoardingPage1Title,
                          text2: languages.onBoardingPage1Message,
                        ),
                        IntroPage(
                          image: 'assets/images/intro_2.png',
                          text1: languages.onBoardingPage2Title,
                          text2: languages.onBoardingPage2Message,
                        ),
                        IntroPage(
                          image: 'assets/images/intro_3.png',
                          text1: languages.onBoardingPage3Title,
                          text2: languages.onBoardingPage3Message,
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: introBloc.pageIndexSubject.stream,
                    builder: (context, snapshot) {
                      return DotsIndicator(
                        dotsCount: 3,
                        position: snapshot.data ?? 0,
                        decorator: DotsDecorator(
                          color: const Color(0xffEEE5FF),
                          activeColor: violet100,
                          size: Size.fromRadius(averageScreenSize * 0.006),
                          activeSize: Size.fromRadius(averageScreenSize * 0.013),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.04,
              width: screenWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    onPressed: () {
                      openScreen(context, const SignUpScreen());
                    },
                    text: languages.signUp,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomButton(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    btnColor: violet20,
                    onPressed: () {
                      openScreen(context, const LoginScreen());
                    },
                    child: Text(
                      languages.login,
                      style: GoogleFonts.inter(
                        color: violet100,
                        fontWeight: FontWeight.w600,
                        fontSize: averageScreenSize * 0.025,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    introBloc.dispose();
    super.dispose();
  }
}

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.image, required this.text1, required this.text2});

  final String image;
  final String text1;
  final String text2;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          widget.image,
          width: averageScreenSize * 0.45,
          height: averageScreenSize * 0.45,
          fit: BoxFit.contain,
        ),
        SizedBox(height: screenHeight * 0.02),
        Container(
          margin: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            children: [
              Text(
                widget.text1,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: black50,
                  fontWeight: FontWeight.w700,
                  fontSize: averageScreenSize * 0.05,
                  height: screenHeight * 0.0015,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                widget.text2,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: white20,
                  fontWeight: FontWeight.w500,
                  fontSize: averageScreenSize * 0.025,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
