import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../common_view/snack_bar_content.dart';
import '../../navigation/main_navigation_screen.dart';

class SignUpBloc {
  final BuildContext context;

  SignUpBloc({required this.context});

  final FirebaseAuth auth = FirebaseAuth.instance;
  GoogleAuthProvider provider = GoogleAuthProvider();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isShowPasswordSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get getIsShowPassword => isShowPasswordSubject.stream;
  Function(bool) get setIsShowPassword => isShowPasswordSubject.add;

  final isEmailEligibleSubject = BehaviorSubject<bool>();
  Stream<bool> get getIsEmailEligible => isEmailEligibleSubject.stream;
  Function(bool) get setIsEmailEligible => isEmailEligibleSubject.add;

  final isTermAcceptSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get getIsTermAccept => isTermAcceptSubject.stream;
  Function(bool) get setIsTermAccept => isTermAcceptSubject.add;

  bool checkButtonEligible() {
    if (nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        isEmailEligibleSubject.value &&
        passwordController.text.trim().isNotEmpty &&
        isTermAcceptSubject.value) {
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

  void createUserWithEmailPassword() async {
    final isReadyToCreate = checkButtonEligible();

    if (isReadyToCreate) {
      try {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        /// SignOut and Move to Login page.
        if (context.mounted) {
          showMySnackBar(message: 'Login successfully', messageType: MessageType.success);
        }

        // await auth.signOut();

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use:') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else if (e.code == 'invalid-email') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else if (e.code == 'operation-not-allowed') {
          if (context.mounted) {
            showMySnackBar(message: e.code, messageType: MessageType.failed);
          }
        } else if (e.code == 'weak-password') {
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
          showMySnackBar(message: 'Something Went Wrong', messageType: MessageType.failed);
        }
      }
    } else {
      showMySnackBar(message: 'Fill all Required detail', messageType: MessageType.warning);
    }
  }

  void signInWithGoogle() async {
    try {
      await auth.signInWithProvider(provider);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-disabled') {
          showMySnackBar(message: e.code, messageType: MessageType.failed);
        } else {
          showMySnackBar(message: e.code, messageType: MessageType.failed);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showMySnackBar(message: 'Something Went Wrong', messageType: MessageType.failed);
      }
    }
  }

  void dispose() {
    nameController.dispose();
    isShowPasswordSubject.close();
    isEmailEligibleSubject.close();
    isTermAcceptSubject.close();
  }
}

/// Sign Up / create user
// email-already-in-use: Thrown if there already exists an account with the given email address.
// invalid-email: Thrown if the email address is not valid.
// operation-not-allowed: Thrown if email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.
// weak-password: Thrown if the password is not strong enough.

/// Sign in google
// user-disabled: Thrown if the user corresponding to the given email has been disabled.
