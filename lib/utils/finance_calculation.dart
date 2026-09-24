import '../modals/firebase_modal/day_finance_overview_modal.dart';
import '../modals/firebase_modal/month_finance_overview_modal.dart';
import '../modals/firebase_modal/transaction_modal.dart';
import 'constant.dart';
import 'transaction_data.dart';

/// The parts of a stored `'DD MMMM YYYY'` transaction date, as the realtime
/// database paths need them.
class TransactionDateKey {
  /// The stored day, unpadded-or-padded exactly as `dateFormat` produced it
  /// (e.g. `'07'`) — kept as a string so existing `day-wise-transactions`
  /// keys never shift.
  final String day;

  /// Key of the `month-wise-transactions` child holding this date, e.g.
  /// `'2026-09'`.
  final String monthKey;

  const TransactionDateKey({required this.day, required this.monthKey});
}

/// `'YYYY-MM'` for [date]. Numeric rather than the locale month name, so it
/// sorts and range-queries correctly and stays stable no matter what
/// language the app displays in — a locale-formatted key would file each
/// language's transactions under a different, unrelated month bucket.
String monthKeyFor(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$year-$month';
}

TransactionDateKey parseTransactionDate(String date) {
  final day = date.split(dateSplitFormat)[0];
  return TransactionDateKey(day: day, monthKey: monthKeyFor(dateFormat.parse(date)));
}

bool _isExpense(TransactionModal transaction) => transaction.transactionType == TransactionType.expense.index;

/// Day overview with [transaction] counted towards it.
DayFinanceOverviewModal dayOverviewAfterAdding(DayFinanceOverviewModal current, TransactionModal transaction) {
  return _dayOverviewShiftedBy(current, transaction, 1);
}

/// Day overview with [transaction] taken back out of it.
DayFinanceOverviewModal dayOverviewAfterRemoving(DayFinanceOverviewModal current, TransactionModal transaction) {
  return _dayOverviewShiftedBy(current, transaction, -1);
}

DayFinanceOverviewModal _dayOverviewShiftedBy(
  DayFinanceOverviewModal current,
  TransactionModal transaction,
  int sign,
) {
  final delta = sign * transaction.amount;

  return DayFinanceOverviewModal(
    expense: _isExpense(transaction) ? current.expense + delta : current.expense,
    income: _isExpense(transaction) ? current.income : current.income + delta,
  );
}

/// Month overview with [transaction] counted towards it, balance recalculated.
FinanceOverviewModal monthOverviewAfterAdding(FinanceOverviewModal current, TransactionModal transaction) {
  return _monthOverviewShiftedBy(current, transaction, 1);
}

/// Month overview with [transaction] taken back out of it, balance recalculated.
FinanceOverviewModal monthOverviewAfterRemoving(FinanceOverviewModal current, TransactionModal transaction) {
  return _monthOverviewShiftedBy(current, transaction, -1);
}

FinanceOverviewModal _monthOverviewShiftedBy(
  FinanceOverviewModal current,
  TransactionModal transaction,
  int sign,
) {
  final delta = sign * transaction.amount;

  final expense = _isExpense(transaction) ? current.expense + delta : current.expense;
  final income = _isExpense(transaction) ? current.income : current.income + delta;
  final balance = (current.budget + income) - expense;

  return FinanceOverviewModal(
    budget: current.budget,
    expense: expense,
    income: income,
    balance: balance,
  );
}
