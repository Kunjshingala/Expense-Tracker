import 'package:firebase_database/firebase_database.dart';

import '../modals/firebase_modal/transaction_modal.dart';
import 'finance_calculation.dart';
import 'firebase_references.dart';
import 'transaction_data.dart';

/// Every path a transaction occupies, relative to the user's `transactions`
/// node. A transaction is stored as its own record twice and referenced from
/// the three month summaries, so a write has to touch five places plus the
/// two running totals.
class _TransactionPaths {
  final String record;
  final String dayRecord;
  final String categoryEntry;
  final String typeEntry;
  final String modeEntry;
  final String dayOverview;
  final String monthOverview;

  const _TransactionPaths({
    required this.record,
    required this.dayRecord,
    required this.categoryEntry,
    required this.typeEntry,
    required this.modeEntry,
    required this.dayOverview,
    required this.monthOverview,
  });

  /// The five paths holding the transaction itself, in write order.
  List<String> get records => [record, dayRecord, categoryEntry, typeEntry, modeEntry];
}

_TransactionPaths _pathsFor(TransactionModal transaction) {
  final date = parseTransactionDate(transaction.date);

  final month = '${FirebaseRealTimeDatabaseRef.monthWiseTransactions}/${date.monthKey}';
  final day = '$month/${FirebaseRealTimeDatabaseRef.dayWiseTransactions}/${date.day}';
  final summary = '$month/${FirebaseRealTimeDatabaseRef.summary}';

  return _TransactionPaths(
    record: '${FirebaseRealTimeDatabaseRef.allTransaction}/${transaction.id}',
    dayRecord: '$day/${FirebaseRealTimeDatabaseRef.transactions}/${transaction.id}',
    categoryEntry:
        '$summary/${FirebaseRealTimeDatabaseRef.categories}/${transaction.category}/${transaction.id}',
    typeEntry:
        '$summary/${FirebaseRealTimeDatabaseRef.transferType}/${transaction.transactionType}/${transaction.id}',
    modeEntry:
        '$summary/${FirebaseRealTimeDatabaseRef.transferMode}/${transaction.transactionMode}/${transaction.id}',
    dayOverview: '$day/${FirebaseRealTimeDatabaseRef.dayFinanceOverview}',
    monthOverview: '$summary/${FirebaseRealTimeDatabaseRef.monthFinanceOverview}',
  );
}

bool _isExpense(TransactionModal transaction) =>
    transaction.transactionType == TransactionType.expense.index;

/// Adds [transaction]'s effect on the running totals into [deltas], multiplied
/// by [sign]: `1` counts it towards them, `-1` takes it back out.
///
/// The month balance moves opposite to an expense and with an income. Its
/// delta does not involve `budget`, so incrementing stays correct whatever the
/// budget is set to later.
void _accumulate(Map<String, int> deltas, TransactionModal transaction, int sign) {
  final paths = _pathsFor(transaction);
  final amount = sign * transaction.amount;

  void bump(String path, int by) {
    if (by == 0) return;
    deltas[path] = (deltas[path] ?? 0) + by;
  }

  if (_isExpense(transaction)) {
    bump('${paths.dayOverview}/expense', amount);
    bump('${paths.monthOverview}/expense', amount);
    bump('${paths.monthOverview}/balance', -amount);
  } else {
    bump('${paths.dayOverview}/income', amount);
    bump('${paths.monthOverview}/income', amount);
    bump('${paths.monthOverview}/balance', amount);
  }
}

/// One atomic `update()` map moving a transaction from [previous] to [next],
/// ready for `DatabaseReference.update` on the user's `transactions` node.
///
/// Pass only [next] to add, only [previous] to remove, or both to edit. A null
/// value removes that path; totals are written as [ServerValue.increment]
/// deltas so two writes that land together both count, and neither overview
/// has to be read first.
///
/// An edit whose date, type or mode changed moves the transaction between
/// buckets: the paths it no longer occupies are removed in the same write that
/// creates the new ones, so the summaries can never disagree with the records.
Map<String, Object?> transactionWriteUpdates({
  TransactionModal? previous,
  TransactionModal? next,
}) {
  assert(previous != null || next != null, 'a write needs a previous, a next, or both');

  final updates = <String, Object?>{};
  final deltas = <String, int>{};

  final previousPaths = previous == null ? const <String>[] : _pathsFor(previous).records;
  final nextPaths = next == null ? const <String>[] : _pathsFor(next).records;

  /// paths the transaction has vacated, including every path when removing.
  for (final path in previousPaths) {
    if (!nextPaths.contains(path)) updates[path] = null;
  }

  if (next != null) {
    final map = next.toMap();
    for (final path in nextPaths) {
      updates[path] = map;
    }
  }

  if (previous != null) _accumulate(deltas, previous, -1);
  if (next != null) _accumulate(deltas, next, 1);

  deltas.forEach((path, delta) {
    if (delta != 0) updates[path] = ServerValue.increment(delta);
  });

  return updates;
}
