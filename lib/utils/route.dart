import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

/// Navigation helpers.
///
/// The `WithoutNavBar` variants push above the persistent bottom navigation
/// bar so it stays visible; use them for screens opened from inside a tab.
/// The plain variants use the root Navigator and cover the bar.

bool canPop(BuildContext context) => Navigator.canPop(context);

void openScreen(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

Future<T?> openScreenWithResult<T extends Object?>(BuildContext context, Widget screen) {
  return Navigator.push<T>(context, MaterialPageRoute<T>(builder: (context) => screen));
}

void openScreenWithReplacePrevious(BuildContext context, Widget screen) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
}

void openScreenWithClearPrevious(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => screen), (route) => false);
}

void closeScreen<T extends Object?>(BuildContext context, [T? result]) {
  if (canPop(context)) Navigator.pop<T>(context, result);
}

/// Keeps the persistent bottom navigation bar visible.
void openScreenWithoutNavBar(BuildContext context, Widget screen) {
  pushWithoutNavBar(context, MaterialPageRoute(builder: (context) => screen));
}

/// Keeps the persistent bottom navigation bar visible.
Future<T?> openScreenWithResultWithoutNavBar<T extends Object?>(BuildContext context, Widget screen) {
  return pushWithoutNavBar<T>(context, MaterialPageRoute<T>(builder: (context) => screen));
}

/// Keeps the persistent bottom navigation bar visible.
void openScreenWithReplacePreviousWithoutNavBar(BuildContext context, Widget screen) {
  pushReplacementWithoutNavBar(context, MaterialPageRoute(builder: (context) => screen));
}
