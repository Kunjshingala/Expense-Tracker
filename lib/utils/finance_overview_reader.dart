import 'package:firebase_database/firebase_database.dart';

import '../modals/firebase_modal/day_finance_overview_modal.dart';
import '../modals/firebase_modal/month_finance_overview_modal.dart';

/// Reads a `day-finance-overview` node, treating a missing node as an empty
/// day rather than throwing. Days are created lazily by the first transaction
/// written to them, so the node legitimately may not exist yet.
Future<DayFinanceOverviewModal> readDayFinanceOverview(DatabaseReference reference) async {
  final snapshot = await reference.get();

  if (!snapshot.exists) return DayFinanceOverviewModal(expense: 0, income: 0);

  return DayFinanceOverviewModal.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
}

/// Reads a `month-finance-overview` node, treating a missing node as an empty
/// month rather than throwing.
Future<FinanceOverviewModal> readMonthFinanceOverview(DatabaseReference reference) async {
  final snapshot = await reference.get();

  if (!snapshot.exists) {
    return FinanceOverviewModal(budget: 0, expense: 0, income: 0, balance: 0);
  }

  return FinanceOverviewModal.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
}
