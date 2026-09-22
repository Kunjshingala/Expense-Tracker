import '../modals/firebase_modal/day_finance_overview_modal.dart';
import '../modals/firebase_modal/month_finance_overview_modal.dart';
import '../modals/firebase_modal/transaction_modal.dart';
import 'finance_calculation.dart';
import 'firebase_references.dart';

/// Every path a deleted transaction has to be unwound from, as one map of
/// relative path to new value, ready for a single atomic
/// `DatabaseReference.update` on the user's `transactions` node.
///
/// A null value removes that path. The two overview paths carry recalculated
/// totals instead, so the removals and the totals they affect commit together.
///
/// [dayOverview] and [monthOverview] are the overviews as currently stored;
/// read them immediately before calling this.
Map<String, Object?> transactionRemovalUpdates({
  required TransactionModal transaction,
  required DayFinanceOverviewModal dayOverview,
  required FinanceOverviewModal monthOverview,
}) {
  final date = parseTransactionDate(transaction.date);

  final month = '${FirebaseRealTimeDatabaseRef.monthWiseTransactions}/${date.monthKey}';
  final day = '$month/${FirebaseRealTimeDatabaseRef.dayWiseTransactions}/${date.day}';
  final summary = '$month/${FirebaseRealTimeDatabaseRef.summary}';

  return {
    /// the transaction itself, in both places it is stored.
    '${FirebaseRealTimeDatabaseRef.allTransaction}/${transaction.id}': null,
    '$day/${FirebaseRealTimeDatabaseRef.transactions}/${transaction.id}': null,

    /// its entries in the three month summaries.
    '$summary/${FirebaseRealTimeDatabaseRef.categories}/${transaction.category}/${transaction.id}': null,
    '$summary/${FirebaseRealTimeDatabaseRef.transferType}/${transaction.transactionType}/${transaction.id}': null,
    '$summary/${FirebaseRealTimeDatabaseRef.transferMode}/${transaction.transactionMode}/${transaction.id}': null,

    /// totals with this transaction taken back out.
    '$day/${FirebaseRealTimeDatabaseRef.dayFinanceOverview}':
        dayOverviewAfterRemoving(dayOverview, transaction).toMap(),
    '$summary/${FirebaseRealTimeDatabaseRef.monthFinanceOverview}':
        monthOverviewAfterRemoving(monthOverview, transaction).toMap(),
  };
}
