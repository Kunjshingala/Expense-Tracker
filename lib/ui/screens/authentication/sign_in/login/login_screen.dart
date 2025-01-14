import 'package:expense_tracker/ui/screens/authentication/sign_in/forgot_password/forgot_password_screen.dart';
import 'package:expense_tracker/ui/screens/authentication/sign_in/login/login_bloc.dart';
import 'package:expense_tracker/ui/screens/authentication/sign_up/sign_up_screen.dart';
import 'package:expense_tracker/utils/custom_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/dimens.dart';
import '../../../../common_view/main_eleveted_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc loginBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    loginBloc = LoginBloc(context: context);
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
          'Login',
          style: GoogleFonts.inter(
            color: dark50Color,
            fontWeight: FontWeight.w600,
            fontSize: averageScreenSize * 0.035,
          ),
        ),
      ),
      backgroundColor: light100Color,
      body: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.08),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<bool>(
                stream: loginBloc.getIsEmailEligible,
                builder: (context, snapshot) {
                  return TextFormField(
                    controller: loginBloc.emailController,
                    cursorColor: light0Color,
                    style: GoogleFonts.inter(
                      color: dark25Color,
                      fontWeight: FontWeight.w500,
                      fontSize: averageScreenSize * 0.03,
                    ),
                    onChanged: (value) {
                      /// validate email
                      loginBloc.emailValidate(value);
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
                stream: loginBloc.getIsEmailEligible,
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
                        padding: EdgeInsetsDirectional.only(start: screenWidth * 0.02, top: screenHeight * 0.01),
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
              SizedBox(height: screenHeight * 0.025),
              StreamBuilder<bool>(
                stream: loginBloc.getIsShowPassword,
                builder: (context, snapshot) {
                  return TextFormField(
                    controller: loginBloc.passwordController,
                    obscureText: snapshot.hasData ? snapshot.data! : true,
                    cursorColor: light0Color,
                    style: GoogleFonts.inter(
                      color: dark25Color,
                      fontWeight: FontWeight.w500,
                      fontSize: averageScreenSize * 0.03,
                    ),
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.075,
                        maxHeight: screenHeight * 0.075,
                        minWidth: screenWidth - (screenWidth * 0.1),
                        maxWidth: screenWidth - (screenWidth * 0.1),
                      ),
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(
                        color: light0Color,
                        fontWeight: FontWeight.w400,
                        fontSize: averageScreenSize * 0.03,
                      ),
                      contentPadding: EdgeInsetsDirectional.symmetric(
                        vertical: screenHeight * 0.025,
                        horizontal: screenWidth * 0.05,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          loginBloc.setIsShowPassword(!(loginBloc.isShowPasswordSubject.valueOrNull ?? true));
                        },
                        icon: snapshot.hasData
                            ? snapshot.data!
                                ? Icon(
                                    CustomIcons.show_icons,
                                    color: light0Color,
                                    size: averageScreenSize * 0.06,
                                  )
                                : const Icon(
                                    CupertinoIcons.eye_slash,
                                    color: light0Color,
                                  )
                            : const Icon(
                                CupertinoIcons.eye_slash,
                                color: light0Color,
                              ),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        maxWidth: averageScreenSize * 0.1,
                        maxHeight: averageScreenSize * 0.1,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: light20Color),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: light20Color),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomElevatedButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                borderRadius: averageScreenSize * 0.03,
                color: violet100Color,
                onPressed: () {
                  loginBloc.signInWithEmailPassword();
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.inter(
                    color: light80Color,
                    fontWeight: FontWeight.w600,
                    fontSize: averageScreenSize * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    color: violet100Color,
                    fontWeight: FontWeight.w500,
                    fontSize: averageScreenSize * 0.028,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Don’t have an account yet?  ',
                      style: GoogleFonts.inter(
                        color: light0Color,
                        fontWeight: FontWeight.w500,
                        fontSize: averageScreenSize * 0.025,
                      ),
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: GoogleFonts.inter(
                        color: violet100Color,
                        fontWeight: FontWeight.w500,
                        fontSize: averageScreenSize * 0.025,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    loginBloc.dispose();
  }
}
