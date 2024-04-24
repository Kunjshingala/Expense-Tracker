import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:expense_tracker/ui/screens/authentication/sign_in/login/login_screen.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/colors.dart';
import '../../common_view/main_eleveted_button.dart';
import '../authentication/sign_up/sign_up_screen.dart';
import 'intro_bloc.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late IntroBloc introBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    introBloc = IntroBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: light100Color,
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
                          introBloc.setPageIndex(index);
                          debugPrint('onPageChanged()---------------------------------->$index , $reason');
                        },
                      ),
                      items: const [
                        IntroPage(
                          image: 'assets/images/intro_1.png',
                          text1: 'Gain total control of your money',
                          text2: 'Become your own money manager and make every cent count',
                        ),
                        IntroPage(
                          image: 'assets/images/intro_2.png',
                          text1: 'Know where your money goes',
                          text2: 'Track your transaction easily, with categories and financial report ',
                        ),
                        IntroPage(
                          image: 'assets/images/intro_3.png',
                          text1: 'Planning ahead',
                          text2: 'Setup your budget for each category so you in control',
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: introBloc.getPageIndex,
                    builder: (context, snapshot) {
                      return DotsIndicator(
                        dotsCount: 3,
                        position: snapshot.data ?? 0,
                        decorator: DotsDecorator(
                          color: const Color(0xffEEE5FF),
                          activeColor: violet100Color,
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
                  CustomElevatedButton(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    borderRadius: averageScreenSize * 0.03,
                    color: violet100Color,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        color: light80Color,
                        fontWeight: FontWeight.w600,
                        fontSize: averageScreenSize * 0.025,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomElevatedButton(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    borderRadius: averageScreenSize * 0.03,
                    color: violet20Color,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.inter(
                        color: violet100Color,
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
    // TODO: implement dispose
    super.dispose();
    introBloc.dispose();
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
                  color: dark50Color,
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
                  color: light20Color,
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
