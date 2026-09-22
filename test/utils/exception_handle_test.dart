import 'package:expense_tracker/utils/exception_handle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authErrorReasonForCode', () {
    test('maps sign-up codes', () {
      expect(authErrorReasonForCode('email-already-in-use'), AuthErrorReason.emailAlreadyInUse);
      expect(authErrorReasonForCode('weak-password'), AuthErrorReason.weakPassword);
    });

    test('maps sign-in codes', () {
      expect(authErrorReasonForCode('user-not-found'), AuthErrorReason.userNotFound);
      expect(authErrorReasonForCode('wrong-password'), AuthErrorReason.wrongPassword);
      expect(authErrorReasonForCode('invalid-credential'), AuthErrorReason.invalidCredential);
    });

    test('maps password-reset codes', () {
      expect(authErrorReasonForCode('expired-action-code'), AuthErrorReason.expiredActionCode);
      expect(authErrorReasonForCode('invalid-action-code'), AuthErrorReason.invalidActionCode);
    });

    test('accepts the auth/ prefixed spelling Firebase uses for reset errors', () {
      expect(authErrorReasonForCode('auth/invalid-email'), AuthErrorReason.invalidEmail);
      expect(authErrorReasonForCode('auth/user-not-found'), AuthErrorReason.userNotFound);
    });

    test('accepts the screaming-case legacy credential code', () {
      expect(authErrorReasonForCode('INVALID_LOGIN_CREDENTIALS'), AuthErrorReason.invalidCredential);
    });

    test('falls back to unknown for an unrecognised code', () {
      expect(authErrorReasonForCode('some-code-firebase-added-later'), AuthErrorReason.unknown);
      expect(authErrorReasonForCode(''), AuthErrorReason.unknown);
    });
  });

  group('authErrorReasonFor', () {
    test('reads the code off a FirebaseAuthException', () {
      final reason = authErrorReasonFor(FirebaseAuthException(code: 'wrong-password'));

      expect(reason, AuthErrorReason.wrongPassword);
    });

    test('does not swallow FirebaseAuthException as a plain FirebaseException', () {
      /// FirebaseAuthException extends FirebaseException, so an `is
      /// FirebaseException` check placed first captures every auth error and
      /// loses its code. This pins the ordering.
      final exception = FirebaseAuthException(code: 'email-already-in-use');

      expect(exception, isA<FirebaseException>());
      expect(authErrorReasonFor(exception), AuthErrorReason.emailAlreadyInUse);
    });

    test('returns unknown for a non-auth FirebaseException', () {
      final reason = authErrorReasonFor(FirebaseException(plugin: 'firebase_database', code: 'permission-denied'));

      expect(reason, AuthErrorReason.unknown);
    });

    test('returns unknown for a PlatformException', () {
      expect(authErrorReasonFor(PlatformException(code: 'sign_in_failed')), AuthErrorReason.unknown);
    });

    test('returns unknown for an arbitrary object', () {
      expect(authErrorReasonFor(Exception('boom')), AuthErrorReason.unknown);
      expect(authErrorReasonFor('a string'), AuthErrorReason.unknown);
    });
  });
}
