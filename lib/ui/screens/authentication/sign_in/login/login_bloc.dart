import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../utils/utils.dart';
import '../../../../common_view/snack_bar.dart';
import '../../../main_home/main_navigation_screen.dart';

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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else if (e.code == 'invalid-email') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else if (e.code == 'user-disabled') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else if (e.code == 'user-not-found') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
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
      await GoogleSignIn().signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      logD(tag, message: e.code);
      if (context.mounted) {
        if (e.code == 'user-disabled') {
          showMySnackBar(message: e.code, messageType: MessageType.failed);
        } else {
          showMySnackBar(message: e.code, messageType: MessageType.failed);
        }
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
