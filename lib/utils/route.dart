import 'package:flutter/material.dart';

bool canPop(BuildContext context) => Navigator.canPop(context);

openScreen(BuildContext context, Widget screen, {bool clearPrevious = false, bool clearAll = false}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

Future<dynamic> openScreenWithResult<T extends Object?>(BuildContext context, Widget screen) async {
  final dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  return result;
}

openScreenWithReplacePrevious(BuildContext context, Widget screen) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
}

openScreenWithClearPrevious(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => screen), (route) => false);
}

closeScreen<T extends Object?>(BuildContext context, [T? result]) {
  if (canPop(context)) Navigator.pop(context, T);
}
