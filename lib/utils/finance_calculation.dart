import '../modals/firebase_modal/day_finance_overview_modal.dart';
import '../modals/firebase_modal/month_finance_overview_modal.dart';
import '../modals/firebase_modal/transaction_modal.dart';
import 'constant.dart';
import 'transaction_data.dart';

/// The parts of a stored `'DD MM YYYY'` transaction date, as the realtime
/// database paths need them.
class TransactionDateKey {
  final String day;
  final String month;
  final String year;

  const TransactionDateKey({required this.day, required this.month, required this.year});

  /// Key of the `month-wise-transactions` child holding this date.
  String get monthKey => '$month-$year';
}

TransactionDateKey parseTransactionDate(String date) {
  final parts = date.split(dateSplitFormat);
  return TransactionDateKey(day: parts[0], month: parts[1], year: parts[2]);
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
