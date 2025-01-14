import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

// Split date with Single space. list[0]->date(DD), list[1]->month(MMMM), list[2]->year(YYYY).
const String dateSplitFormat = ' ';
