import 'package:expense_tracker/ui/screens/authentication/sign_in/login/login_screen.dart';
import 'package:expense_tracker/ui/screens/authentication/sign_up/sign_up_bloc.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/utils/custom_icons.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common_view/main_eleveted_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late SignUpBloc signUpBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    signUpBloc = SignUpBloc(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: screenWidth * 0.12,
        backgroundColor: light100Color,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: screenWidth * 0.03),
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
          'Sign Up',
          style: GoogleFonts.inter(
            color: dark50Color,
            fontWeight: FontWeight.w600,
            fontSize: averageScreenSize * 0.035,
          ),
        ),
      ),
      backgroundColor: light100Color,
      body: Padding(
        padding:
            EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.08),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: signUpBloc.nameController,
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
                  hintText: 'Name',
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
                    borderSide: const BorderSide(color: light20Color),
                    borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: light20Color),
                    borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              StreamBuilder<bool>(
                stream: signUpBloc.getIsEmailEligible,
                builder: (context, snapshot) {
                  return TextFormField(
                    controller: signUpBloc.emailController,
                    cursorColor: light0Color,
                    style: GoogleFonts.inter(
                      color: dark25Color,
                      fontWeight: FontWeight.w500,
                      fontSize: averageScreenSize * 0.03,
                    ),
                    onChanged: (value) {
                      /// validate email
                      signUpBloc.emailValidate(value);
                    },
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
                stream: signUpBloc.getIsEmailEligible,
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
              SizedBox(height: screenHeight * 0.025),
              StreamBuilder<bool>(
                stream: signUpBloc.getIsShowPassword,
                builder: (context, snapshot) {
                  return TextFormField(
                    controller: signUpBloc.passwordController,
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
                          signUpBloc
                              .setIsShowPassword(!(signUpBloc.isShowPasswordSubject.valueOrNull ?? true));
                        },
                        icon: snapshot.hasData
                            ? snapshot.data!
                                ? Icon(
                                    CustomIcons.show_icons,
                                    color: light0Color,
                                    size: averageScreenSize * 0.06,
                                    weight: 1,
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
              SizedBox(height: screenHeight * 0.020),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StreamBuilder<bool>(
                    stream: signUpBloc.getIsTermAccept,
                    builder: (context, snapshot) {
                      return Checkbox(
                        value: snapshot.data ?? false,
                        onChanged: (value) {
                          signUpBloc.setIsTermAccept(value!);
                        },
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(averageScreenSize * 0.01),
                          side: const BorderSide(color: violet100Color),
                        ),
                      );
                    },
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'By signing up, you agree to the ',
                            style: GoogleFonts.inter(
                              color: dark100Color,
                              fontWeight: FontWeight.w500,
                              fontSize: averageScreenSize * 0.025,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms of Service and Privacy Policy',
                            style: GoogleFonts.inter(
                              color: violet100Color,
                              fontWeight: FontWeight.w500,
                              fontSize: averageScreenSize * 0.025,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              CustomElevatedButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                borderRadius: averageScreenSize * 0.03,
                color: violet100Color,
                onPressed: () {
                  signUpBloc.createUserWithEmailPassword();
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
              SizedBox(height: screenHeight * 0.020),
              Text(
                'Or with',
                style: GoogleFonts.inter(
                  color: light0Color,
                  fontWeight: FontWeight.w500,
                  fontSize: averageScreenSize * 0.025,
                ),
              ),
              SizedBox(height: screenHeight * 0.020),
              CustomElevatedButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                borderRadius: averageScreenSize * 0.03,
                color: light100Color,
                borderColor: light20Color,
                onPressed: () {
                  signUpBloc.signInWithGoogle();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/fonts/third_party_icon/google_icons.svg',
                      width: averageScreenSize * 0.05,
                      height: averageScreenSize * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Text(
                      'Sign Up with Google',
                      style: GoogleFonts.inter(
                        color: dark50Color,
                        fontWeight: FontWeight.w600,
                        fontSize: averageScreenSize * 0.026,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: GoogleFonts.inter(
                        color: light0Color,
                        fontWeight: FontWeight.w500,
                        fontSize: averageScreenSize * 0.028,
                      ),
                    ),
                    TextSpan(
                      text: 'Login',
                      style: GoogleFonts.inter(
                        color: violet100Color,
                        fontWeight: FontWeight.w600,
                        fontSize: averageScreenSize * 0.028,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
    signUpBloc.dispose();
  }
}
