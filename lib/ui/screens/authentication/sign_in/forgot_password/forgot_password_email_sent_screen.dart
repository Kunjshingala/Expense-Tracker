import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/dimens.dart';
import '../../../../common_view/common_button.dart';
import '../login/login_screen.dart';

class ForgotPasswordEmailSentScreen extends StatelessWidget {
  const ForgotPasswordEmailSentScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white100,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: EdgeInsetsDirectional.only(
          start: screenWidth * 0.05,
          end: screenWidth * 0.05,
          top: screenHeight * 0.08,
        ),
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/email_sent.png',
                      width: averageScreenSize * 0.5,
                      height: averageScreenSize * 0.5,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      languages.yourEmailIsOnTheWay,
                      style: GoogleFonts.inter(
                        color: black100,
                        fontWeight: FontWeight.w600,
                        fontSize: averageScreenSize * 0.04,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth - (screenWidth * 0.25)),
                      child: Text(
                        languages.checkEmailMsg(email),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: black100,
                          fontWeight: FontWeight.w500,
                          fontSize: averageScreenSize * 0.025,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: screenHeight * 0.04,
              child: CustomButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Text(
                  languages.continue_,
                  style: GoogleFonts.inter(
                    color: white80,
                    fontWeight: FontWeight.w600,
                    fontSize: averageScreenSize * 0.025,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
