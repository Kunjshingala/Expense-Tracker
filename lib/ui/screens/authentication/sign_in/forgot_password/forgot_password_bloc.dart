import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../common_view/snack_bar_content.dart';
import 'forgot_password_email_sent_screen.dart';

class ForgotPasswordBloc {
  final BuildContext context;

  ForgotPasswordBloc({required this.context});

  final FirebaseAuth auth = FirebaseAuth.instance;

  final emailController = TextEditingController();

  final isEmailEligibleSubject = BehaviorSubject<bool>();
  Stream<bool> get getIsEmailEligible => isEmailEligibleSubject.stream;
  Function(bool) get setIsEmailEligible => isEmailEligibleSubject.add;

  bool checkButtonEligible() {
    if (emailController.text.trim().isNotEmpty && isEmailEligibleSubject.value) {
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

  void sendResetPassEmail() async {
    final isReadyToSend = checkButtonEligible();

    try {
      await auth.sendPasswordResetEmail(email: emailController.text.trim());

      if (context.mounted) {
        if (context.mounted) {
          showMySnackBar('Sent Successfully', MessageType.success);
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ForgotPasswordEmailSentScreen(email: emailController.text.trim())),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'auth/invalid-email') {
        if (context.mounted) {
          showMySnackBar(e.code, MessageType.failed);
        }
      } else if (e.code == 'auth/missing-android-pkg-name') {
        if (context.mounted) {
          showMySnackBar(e.code, MessageType.failed);
        }
      } else if (e.code == 'auth/missing-continue-uri') {
        if (context.mounted) {
          showMySnackBar(e.code, MessageType.failed);
        }
      } else if (e.code == 'auth/missing-ios-bundle-id') {
        if (context.mounted) {
          showMySnackBar(e.code, MessageType.failed);
        }
      } else if (e.code == 'auth/invalid-continue-uri') {
        if (context.mounted) {
          showMySnackBar(e.code, MessageType.failed);
        }
      } else if (e.code == 'auth/unauthorized-continue-uri') {
        if (context.mounted) {
          showMySnackBar(e.code, MessageType.failed);
        }
      } else if (e.code == 'auth/user-not-found') {
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

    if (isReadyToSend) {
    } else {
      if (context.mounted) {
        showMySnackBar('Fill all Required detail', MessageType.warning);
      }
    }
  }

  void dispose() {
    emailController.dispose();
    isEmailEligibleSubject.close();
  }
}
