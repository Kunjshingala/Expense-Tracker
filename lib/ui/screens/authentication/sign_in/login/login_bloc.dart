import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../common_view/snack_bar_content.dart';
import '../../../navigation/main_navigation_screen.dart';

class LoginBloc {
  final BuildContext context;

  LoginBloc({required this.context});

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
          showMySnackBar('Login Successfully', MessageType.success);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          if (context.mounted) {
            showMySnackBar(e.code, MessageType.failed);
          }
        } else if (e.code == 'invalid-email') {
          if (context.mounted) {
            showMySnackBar(e.code, MessageType.failed);
          }
        } else if (e.code == 'user-disabled') {
          if (context.mounted) {
            showMySnackBar(e.code, MessageType.failed);
          }
        } else if (e.code == 'user-not-found') {
          if (context.mounted) {
            showMySnackBar(e.code, MessageType.failed);
          }
        } else {
          if (context.mounted) {
            showMySnackBar(e.code, MessageType.failed);
          }
        }
      } catch (e) {
        if (context.mounted) {
          showMySnackBar('Something went wrong', MessageType.failed);
        }
      }
    } else {
      showMySnackBar('Fill all Required detail', MessageType.warning);
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
