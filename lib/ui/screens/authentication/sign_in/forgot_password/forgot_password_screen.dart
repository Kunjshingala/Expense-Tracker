import 'package:expense_tracker/ui/screens/authentication/sign_in/forgot_password/forgot_password_bloc.dart';
import 'package:expense_tracker/utils/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/dimens.dart';
import '../../../../common_view/main_eleveted_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late ForgotPasswordBloc forgotPasswordBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    forgotPasswordBloc = ForgotPasswordBloc(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: screenWidth * 0.12,
        backgroundColor: light100Color,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: screenWidth * 0.03),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              CustomIcons.arrow_left_icons,
              color: dark50Color,
              size: averageScreenSize * 0.06,
              weight: 1,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.inter(
            color: dark50Color,
            fontWeight: FontWeight.w600,
            fontSize: averageScreenSize * 0.035,
          ),
        ),
      ),
      backgroundColor: light100Color,
      body: Padding(
        padding: EdgeInsetsDirectional.only(
          start: screenWidth * 0.05,
          end: screenWidth * 0.05,
          top: screenHeight * 0.08,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don’t worry. \nEnter your email and we’ll send you a link to reset your password.',
                style: GoogleFonts.inter(
                  color: dark100Color,
                  fontWeight: FontWeight.w600,
                  fontSize: averageScreenSize * 0.04,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),
              StreamBuilder<bool>(
                stream: forgotPasswordBloc.getIsEmailEligible,
                builder: (context, snapshot) {
                  return TextFormField(
                    controller: forgotPasswordBloc.emailController,
                    cursorColor: light0Color,
                    style: GoogleFonts.inter(
                      color: dark25Color,
                      fontWeight: FontWeight.w500,
                      fontSize: averageScreenSize * 0.03,
                    ),
                    onChanged: (value) {
                      /// validate email
                      forgotPasswordBloc.emailValidate(value);
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.075,
                        maxHeight: screenHeight * 0.075,
                        minWidth: screenWidth - (screenWidth * 0.1),
                        maxWidth: screenWidth - (screenWidth * 0.1),
                      ),
                      hintText: 'Email',
                      hintStyle: GoogleFonts.inter(
                        color: light0Color,
                        fontWeight: FontWeight.w400,
                        fontSize: averageScreenSize * 0.03,
                      ),
                      contentPadding: EdgeInsetsDirectional.symmetric(
                        vertical: screenHeight * 0.025,
                        horizontal: screenWidth * 0.05,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: snapshot.data ?? true ? light20Color : red100Color),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: snapshot.data ?? true ? light20Color : red100Color),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                    ),
                  );
                },
              ),

              /// display Error Text at wrong email.
              StreamBuilder<bool>(
                stream: forgotPasswordBloc.getIsEmailEligible,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasData) {
                    if (snapshot.data!) {
                      return Container();
                    } else {
                      return Container(
                        width: screenWidth,
                        alignment: AlignmentDirectional.centerStart,
                        padding:
                            EdgeInsetsDirectional.only(start: screenWidth * 0.02, top: screenHeight * 0.01),
                        child: Column(
                          children: [
                            Text(
                              'Enter Valid Email.',
                              style: GoogleFonts.inter(
                                color: red100Color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomElevatedButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                borderRadius: averageScreenSize * 0.03,
                color: violet100Color,
                onPressed: () {
                  forgotPasswordBloc.sendResetPassEmail();
                },
                child: Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    color: light80Color,
                    fontWeight: FontWeight.w600,
                    fontSize: averageScreenSize * 0.025,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
