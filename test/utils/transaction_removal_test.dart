import 'package:expense_tracker/modals/firebase_modal/day_finance_overview_modal.dart';
import 'package:expense_tracker/modals/firebase_modal/month_finance_overview_modal.dart';
import 'package:expense_tracker/modals/firebase_modal/transaction_modal.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:expense_tracker/utils/transaction_removal.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModal transaction({
  String id = 'txn-1',
  int amount = 200,
  TransactionType type = TransactionType.expense,
  TransactionMode mode = TransactionMode.cash,
  int category = 3,
  String date = '12 04 2024',
}) {
  return TransactionModal(
    id: id,
    amount: amount,
    transactionType: type.index,
    transactionMode: mode.index,
    category: category,
    date: date,
    time: 0,
    description: null,
    location: null,
    imageUrl: null,
  );
}

Map<String, Object?> updatesFor(TransactionModal txn, {
  DayFinanceOverviewModal? day,
  FinanceOverviewModal? month,
}) {
  return transactionRemovalUpdates(
    transaction: txn,
    dayOverview: day ?? DayFinanceOverviewModal(expense: 500, income: 300),
    monthOverview: month ?? FinanceOverviewModal(budget: 1000, expense: 500, income: 300, balance: 800),
  );
}

void main() {
  group('transactionRemovalUpdates', () {
    test('nulls the transaction out of all-transactions', () {
      final updates = updatesFor(transaction());

      expect(updates['all-transactions/txn-1'], isNull);
      expect(updates.containsKey('all-transactions/txn-1'), isTrue);
    });

    test('nulls the transaction out of its day node', () {
      final updates = updatesFor(transaction());

      const path = 'month-wise-transactions/04-2024/day-wise-transactions/12/transactions/txn-1';
      expect(updates.containsKey(path), isTrue);
      expect(updates[path], isNull);
    });

    test('nulls the transaction out of the category, type and mode summaries', () {
      final updates = updatesFor(
        transaction(category: 3, type: TransactionType.income, mode: TransactionMode.online),
      );

      expect(updates.containsKey('month-wise-transactions/04-2024/summary/categories/3/txn-1'), isTrue);
      expect(updates.containsKey('month-wise-transactions/04-2024/summary/transfer-type/1/txn-1'), isTrue);
      expect(updates.containsKey('month-wise-transactions/04-2024/summary/transfer-mode/1/txn-1'), isTrue);
    });

    test('writes the recalculated day overview', () {
      final updates = updatesFor(
        transaction(amount: 200, type: TransactionType.expense),
        day: DayFinanceOverviewModal(expense: 500, income: 300),
      );

      final day = updates['month-wise-transactions/04-2024/day-wise-transactions/12/day-finance-overview'];
      expect(day, {'expense': 300, 'income': 300});
    });

    test('writes the recalculated month overview', () {
      final updates = updatesFor(
        transaction(amount: 200, type: TransactionType.expense),
        month: FinanceOverviewModal(budget: 1000, expense: 500, income: 300, balance: 800),
      );

      final month = updates['month-wise-transactions/04-2024/summary/month-finance-overview'];
      expect(month, {
        'budget': 1000,
        'expense': 300,
        'income': 300,
        'balance': 1000,
      });
    });

    test('produces exactly the seven paths a removal touches', () {
      expect(updatesFor(transaction()).keys, hasLength(7));
    });

    test('keys are relative paths with no leading slash', () {
      for (final key in updatesFor(transaction()).keys) {
        expect(key.startsWith('/'), isFalse, reason: '$key must be relative to the user transactions node');
      }
    });
  });
}
