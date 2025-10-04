import 'package:expense_tracker/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/constant.dart';
import '../../../../../utils/custom_icons.dart';
import '../../../../common_view/common_button.dart';
import '../../sign_up/sign_up_screen.dart';
import '../forgot_password/forgot_password_screen.dart';
import 'login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc loginBloc;

  @override
  void didChangeDependencies() {
    loginBloc = LoginBloc(context: context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: screenWidth * 0.12,
        backgroundColor: white100,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: screenWidth * 0.03),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              CustomIcons.arrow_left_icons,
              color: black50,
              size: averageScreenSize * 0.06,
              weight: 1,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          languages.login,
          style: GoogleFonts.inter(
            color: black50,
            fontWeight: FontWeight.w600,
            fontSize: averageScreenSize * 0.035,
          ),
        ),
      ),
      backgroundColor: white100,
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
                    cursorColor: white0,
                    style: GoogleFonts.inter(
                      color: black25,
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
                      hintText: languages.email,
                      hintStyle: GoogleFonts.inter(
                        color: white0,
                        fontWeight: FontWeight.w400,
                        fontSize: averageScreenSize * 0.03,
                      ),
                      contentPadding: EdgeInsetsDirectional.symmetric(
                        vertical: screenHeight * 0.025,
                        horizontal: screenWidth * 0.05,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: snapshot.data ?? true ? white20 : red100),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: snapshot.data ?? true ? white20 : red100),
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
                              languages.emailValidationMsg,
                              style: GoogleFonts.inter(
                                color: red100,
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
                    cursorColor: white0,
                    style: GoogleFonts.inter(
                      color: black25,
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
                      hintText: languages.password,
                      hintStyle: GoogleFonts.inter(
                        color: white0,
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
                                    color: white0,
                                    size: averageScreenSize * 0.06,
                                  )
                                : const Icon(
                                    CupertinoIcons.eye_slash,
                                    color: white0,
                                  )
                            : const Icon(
                                CupertinoIcons.eye_slash,
                                color: white0,
                              ),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        maxWidth: averageScreenSize * 0.1,
                        maxHeight: averageScreenSize * 0.1,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: white20),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: white20),
                        borderRadius: BorderRadius.circular(averageScreenSize * 0.025),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                onPressed: () {
                  loginBloc.signInWithEmailPassword();
                },
                child: Text(
                  languages.login,
                  style: GoogleFonts.inter(
                    color: white80,
                    fontWeight: FontWeight.w600,
                    fontSize: averageScreenSize * 0.025,
                  ),
                ),
              ),

              if (isGoogleLogin) ...[
                SizedBox(height: screenHeight * 0.03),
                CustomButton(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.07,
                  btnColor: white100,
                  borderColor: white20,
                  onPressed: () {
                    loginBloc.signInWithGoogle();
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
                        languages.signUpWithGoogle,
                        style: GoogleFonts.inter(
                          color: black50,
                          fontWeight: FontWeight.w600,
                          fontSize: averageScreenSize * 0.026,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: screenHeight * 0.020),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                },
                child: Text(
                  languages.forgotPassword,
                  style: GoogleFonts.inter(
                    color: violet100,
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
                      text: '${languages.dontHaveAnAccountYet} ',
                      style: GoogleFonts.inter(
                        color: white0,
                        fontWeight: FontWeight.w500,
                        fontSize: averageScreenSize * 0.025,
                      ),
                    ),
                    TextSpan(
                      text: languages.signUp,
                      style: GoogleFonts.inter(
                        color: violet100,
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
}
