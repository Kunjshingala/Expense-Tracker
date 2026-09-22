import 'package:expense_tracker/main.dart';

import 'exception_handle.dart';

/// The message to show the user for a caught authentication failure.
///
/// Falls back to the generic error for anything without a specific message,
/// so a code Firebase adds later never reaches the user as a raw string.
String authErrorMessage(Object exception) {
  switch (authErrorReasonFor(exception)) {
    case AuthErrorReason.emailAlreadyInUse:
      return languages.authEmailAlreadyInUse;
    case AuthErrorReason.invalidEmail:
      return languages.authInvalidEmail;
    case AuthErrorReason.weakPassword:
      return languages.authWeakPassword;
    case AuthErrorReason.userNotFound:
      return languages.authUserNotFound;
    case AuthErrorReason.wrongPassword:
      return languages.authWrongPassword;
    case AuthErrorReason.invalidCredential:
      return languages.authInvalidCredential;
    case AuthErrorReason.accountExistsWithDifferentCredential:
      return languages.authAccountExistsWithDifferentCredential;
    case AuthErrorReason.userDisabled:
      return languages.authUserDisabled;
    case AuthErrorReason.tooManyRequests:
      return languages.authTooManyRequests;
    case AuthErrorReason.userTokenExpired:
      return languages.authUserTokenExpired;
    case AuthErrorReason.networkRequestFailed:
      return languages.authNetworkRequestFailed;
    case AuthErrorReason.operationNotAllowed:
      return languages.authOperationNotAllowed;
    case AuthErrorReason.expiredActionCode:
      return languages.authExpiredActionCode;
    case AuthErrorReason.invalidActionCode:
      return languages.authInvalidActionCode;
    case AuthErrorReason.unknown:
      return languages.somethingWentWrong;
  }
}
