import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../utils/auth_error_message.dart';
import '../../../../../utils/utils.dart';
import '../../../../common_view/snack_bar.dart';
import '../../../main_home/main_navigation_screen.dart';
import '../../../../../utils/route.dart';

class LoginBloc {
  final BuildContext context;

  LoginBloc({required this.context});

  static const String tag = "LoginBloc";

  final FirebaseAuth auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isShowPasswordSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getIsShowPassword => isShowPasswordSubject.stream;

  Function(bool) get setIsShowPassword => isShowPasswordSubject.add;

  final isEmailEligibleSubject = BehaviorSubject<bool>();

  Stream<bool> get getIsEmailEligible => isEmailEligibleSubject.stream;

  Function(bool) get setIsEmailEligible => isEmailEligibleSubject.add;

  bool checkButtonEligible() {
    if (emailController.text.trim().isNotEmpty &&
        isEmailEligibleSubject.value &&
        passwordController.text.trim().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void emailValidate(String emailText) {
    String value =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(value);

    setIsEmailEligible(regExp.hasMatch(emailText));
  }

  void signInWithEmailPassword() async {
    final isReadyToLogin = checkButtonEligible();

    if (isReadyToLogin) {
      try {
        await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (context.mounted) {
          showMySnackBar(message: languages.loginSuccessfully);

          openScreenWithClearPrevious(context, const MainNavigationScreen());
        }
      } on FirebaseAuthException catch (e) {
        logD(tag, message: e.code);
        if (context.mounted) {
          showMySnackBar(message: authErrorMessage(e), messageType: MessageType.failed);
        }
      } catch (e) {
        if (context.mounted) {
          showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
        }
      }
    } else {
      showMySnackBar(message: languages.fieldValidationMsg, messageType: MessageType.warning);
    }
  }

  void signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.signOut();

      /// Trigger the authentication flow. Throws rather than returning
      /// null when the user backs out; see the GoogleSignInException catch.
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      /// Obtain the auth details from the request. This is a plain getter
      /// now, and carries only the id token.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      /// Create a new credential. Access tokens moved to the separate
      /// authorization client in 7.x, and Firebase only needs one of the
      /// two tokens.
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (context.mounted) {
        openScreenWithClearPrevious(context, const MainNavigationScreen());
      }
    } on GoogleSignInException catch (e) {
      logD(tag, message: '${e.code} ${e.description}');

      /// backing out of the account picker is not an error worth showing.
      if (e.code == GoogleSignInExceptionCode.canceled) return;

      if (context.mounted) showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } on FirebaseAuthException catch (e) {
      logD(tag, message: e.code);
      if (context.mounted) {
        showMySnackBar(message: authErrorMessage(e), messageType: MessageType.failed);
      }
    } on PlatformException catch (e) {
      logD(tag, message: e.toString());
      if (context.mounted) showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } catch (e) {
      logD(tag, message: e.toString());
      if (context.mounted) showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isShowPasswordSubject.close();
    isEmailEligibleSubject.close();
  }
}

// wrong-password: Thrown if the password is invalid for the given email, or the account corresponding to the email doesn't have a password set.
// invalid-email: Thrown if the email address is not valid.
// user-disabled: Thrown if the user corresponding to the given email has been disabled.
// user-not-found: Thrown if there is no user corresponding to the given email.
