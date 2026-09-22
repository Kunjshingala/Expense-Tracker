import 'package:firebase_auth/firebase_auth.dart';

/// Why an authentication call failed, in terms the UI can show a message for.
///
/// Firebase spells the same failure several ways across its methods — bare
/// (`user-not-found`), `auth/` prefixed on the password-reset calls, and
/// screaming case on the legacy credential error — so many codes collapse onto
/// one reason here.
///
/// Codes are documented per method at
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth-class.html
enum AuthErrorReason {
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  userNotFound,
  wrongPassword,
  invalidCredential,
  accountExistsWithDifferentCredential,
  userDisabled,
  tooManyRequests,
  userTokenExpired,
  networkRequestFailed,
  operationNotAllowed,
  expiredActionCode,
  invalidActionCode,

  /// no specific message; the caller should fall back to its generic error.
  unknown,
}

const Map<String, AuthErrorReason> _reasonByCode = {
  'email-already-in-use': AuthErrorReason.emailAlreadyInUse,
  'invalid-email': AuthErrorReason.invalidEmail,
  'weak-password': AuthErrorReason.weakPassword,
  'user-not-found': AuthErrorReason.userNotFound,
  'wrong-password': AuthErrorReason.wrongPassword,
  'invalid-credential': AuthErrorReason.invalidCredential,
  'invalid_login_credentials': AuthErrorReason.invalidCredential,
  'invalid-verification-code': AuthErrorReason.invalidCredential,
  'invalid-verification-id': AuthErrorReason.invalidCredential,
  'account-exists-with-different-credential': AuthErrorReason.accountExistsWithDifferentCredential,
  'user-disabled': AuthErrorReason.userDisabled,
  'too-many-requests': AuthErrorReason.tooManyRequests,
  'user-token-expired': AuthErrorReason.userTokenExpired,
  'network-request-failed': AuthErrorReason.networkRequestFailed,
  'operation-not-allowed': AuthErrorReason.operationNotAllowed,
  'expired-action-code': AuthErrorReason.expiredActionCode,
  'invalid-action-code': AuthErrorReason.invalidActionCode,
  'missing-android-pkg-name': AuthErrorReason.operationNotAllowed,
  'missing-continue-uri': AuthErrorReason.operationNotAllowed,
  'missing-ios-bundle-id': AuthErrorReason.operationNotAllowed,
  'invalid-continue-uri': AuthErrorReason.operationNotAllowed,
  'unauthorized-continue-uri': AuthErrorReason.operationNotAllowed,
};

/// Maps a Firebase auth error code onto a reason, normalising the `auth/`
/// prefix and case that Firebase is inconsistent about.
AuthErrorReason authErrorReasonForCode(String code) {
  final normalised = code.toLowerCase().replaceFirst(RegExp(r'^auth/'), '');

  return _reasonByCode[normalised] ?? AuthErrorReason.unknown;
}

/// Maps a caught object onto a reason.
///
/// FirebaseAuthException must be tested before FirebaseException: it is a
/// subclass, so checking the parent first captures every auth error and
/// discards its code.
AuthErrorReason authErrorReasonFor(Object exception) {
  if (exception is FirebaseAuthException) return authErrorReasonForCode(exception.code);

  return AuthErrorReason.unknown;
}
