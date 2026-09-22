import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/custom_icons.dart';
import '../../../../../utils/dimens.dart';
import '../../../../common_view/common_button.dart';
import 'forgot_password_bloc.dart';
import '../../../../../utils/route.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late ForgotPasswordBloc forgotPasswordBloc;

  @override
  void didChangeDependencies() {
    forgotPasswordBloc = ForgotPasswordBloc(context: context);
    super.didChangeDependencies();
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
              closeScreen(context);
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
          languages.forgotPassword,
          style: GoogleFonts.inter(
            color: black50,
            fontWeight: FontWeight.w600,
            fontSize: averageScreenSize * 0.035,
          ),
        ),
      ),
      backgroundColor: white100,
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
                languages.forgotPassMsg,
                style: GoogleFonts.inter(
                  color: black100,
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
                    cursorColor: white0,
                    style: GoogleFonts.inter(
                      color: black25,
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
              SizedBox(height: screenHeight * 0.05),
              CustomButton(
                width: screenWidth * 0.9,
                height: screenHeight * 0.07,
                onPressed: () {
                  forgotPasswordBloc.sendResetPassEmail();
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
            ],
          ),
        ),
      ),
    );
  }
}
