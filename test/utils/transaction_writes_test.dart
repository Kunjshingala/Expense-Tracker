import 'package:expense_tracker/modals/firebase_modal/transaction_modal.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:expense_tracker/utils/transaction_writes.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModal transaction({
  String id = 'txn-1',
  int amount = 200,
  TransactionType type = TransactionType.expense,
  TransactionMode mode = TransactionMode.cash,
  int category = 3,
  String date = '12 04 2024',
  String? description,
}) {
  return TransactionModal(
    id: id,
    amount: amount,
    transactionType: type.index,
    transactionMode: mode.index,
    category: category,
    date: date,
    time: 0,
    description: description,
    location: null,
    imageUrl: null,
  );
}

/// The shape `ServerValue.increment` produces, so the tests assert on the
/// delta actually sent to Firebase rather than on an opaque object.
Map<String, Object?> increment(num delta) => {
      '.sv': {'increment': delta}
    };

const month = 'month-wise-transactions/04-2024';
const day = '$month/day-wise-transactions/12';
const summary = '$month/summary';

void main() {
  group('adding a transaction', () {
    test('writes the record into all five places it is stored', () {
      final updates = transactionWriteUpdates(next: transaction());
      final map = transaction().toMap();

      expect(updates['all-transactions/txn-1'], map);
      expect(updates['$day/transactions/txn-1'], map);
      expect(updates['$summary/categories/3/txn-1'], map);
      expect(updates['$summary/transfer-type/0/txn-1'], map);
      expect(updates['$summary/transfer-mode/0/txn-1'], map);
    });

    test('an expense raises both expense totals and lowers the balance', () {
      final updates = transactionWriteUpdates(next: transaction(amount: 200));

      expect(updates['$day/day-finance-overview/expense'], increment(200));
      expect(updates['$summary/month-finance-overview/expense'], increment(200));
      expect(updates['$summary/month-finance-overview/balance'], increment(-200));
    });

    test('an income raises both income totals and raises the balance', () {
      final updates = transactionWriteUpdates(
        next: transaction(amount: 150, type: TransactionType.income, category: -1),
      );

      expect(updates['$day/day-finance-overview/income'], increment(150));
      expect(updates['$summary/month-finance-overview/income'], increment(150));
      expect(updates['$summary/month-finance-overview/balance'], increment(150));
    });

    test('an expense never touches the income totals', () {
      final updates = transactionWriteUpdates(next: transaction());

      expect(updates.containsKey('$day/day-finance-overview/income'), isFalse);
      expect(updates.containsKey('$summary/month-finance-overview/income'), isFalse);
    });

    test('never writes budget, so a month budget survives every transaction', () {
      final updates = transactionWriteUpdates(next: transaction());

      expect(updates.containsKey('$summary/month-finance-overview/budget'), isFalse);
    });

    test('produces exactly the five records and three totals it touches', () {
      expect(transactionWriteUpdates(next: transaction()).keys, hasLength(8));
    });
  });

  group('removing a transaction', () {
    test('nulls all five records', () {
      final updates = transactionWriteUpdates(previous: transaction());

      expect(updates['all-transactions/txn-1'], isNull);
      expect(updates['$day/transactions/txn-1'], isNull);
      expect(updates['$summary/categories/3/txn-1'], isNull);
      expect(updates['$summary/transfer-type/0/txn-1'], isNull);
      expect(updates['$summary/transfer-mode/0/txn-1'], isNull);
    });

    test('takes the amount back out of the totals', () {
      final updates = transactionWriteUpdates(previous: transaction(amount: 200));

      expect(updates['$day/day-finance-overview/expense'], increment(-200));
      expect(updates['$summary/month-finance-overview/expense'], increment(-200));
      expect(updates['$summary/month-finance-overview/balance'], increment(200));
    });
  });

  group('editing a transaction', () {
    test('an amount change moves the totals by the difference only', () {
      final updates = transactionWriteUpdates(
        previous: transaction(amount: 200),
        next: transaction(amount: 250),
      );

      expect(updates['$day/day-finance-overview/expense'], increment(50));
      expect(updates['$summary/month-finance-overview/expense'], increment(50));
      expect(updates['$summary/month-finance-overview/balance'], increment(-50));
    });

    test('an edit that changes no money writes no totals at all', () {
      final updates = transactionWriteUpdates(
        previous: transaction(),
        next: transaction(description: 'now with a note'),
      );

      expect(updates.keys.where((k) => k.contains('finance-overview')), isEmpty);
      expect(updates['all-transactions/txn-1'], isNotNull);
    });

    test('keeping the same paths overwrites them rather than nulling them', () {
      final updates = transactionWriteUpdates(
        previous: transaction(amount: 200),
        next: transaction(amount: 250),
      );

      expect(updates['all-transactions/txn-1'], isNotNull);
      expect(updates['$day/transactions/txn-1'], isNotNull);
    });

    test('flipping expense to income unwinds one total and builds the other', () {
      final updates = transactionWriteUpdates(
        previous: transaction(amount: 200),
        next: transaction(amount: 200, type: TransactionType.income),
      );

      expect(updates['$day/day-finance-overview/expense'], increment(-200));
      expect(updates['$day/day-finance-overview/income'], increment(200));

      /// balance rises twice: once losing the expense, once gaining the income.
      expect(updates['$summary/month-finance-overview/balance'], increment(400));
    });

    test('flipping expense to income vacates the old transfer-type bucket', () {
      final updates = transactionWriteUpdates(
        previous: transaction(),
        next: transaction(type: TransactionType.income),
      );

      expect(updates['$summary/transfer-type/0/txn-1'], isNull);
      expect(updates['$summary/transfer-type/1/txn-1'], isNotNull);
    });

    test('changing the mode vacates the old transfer-mode bucket', () {
      final updates = transactionWriteUpdates(
        previous: transaction(),
        next: transaction(mode: TransactionMode.online),
      );

      expect(updates['$summary/transfer-mode/0/txn-1'], isNull);
      expect(updates['$summary/transfer-mode/1/txn-1'], isNotNull);
    });

    test('moving to another month empties the old month and fills the new one', () {
      final updates = transactionWriteUpdates(
        previous: transaction(amount: 200, date: '12 04 2024'),
        next: transaction(amount: 200, date: '03 05 2024'),
      );

      const newMonth = 'month-wise-transactions/05-2024';
      const newDay = '$newMonth/day-wise-transactions/03';

      /// every old path is vacated.
      expect(updates['$day/transactions/txn-1'], isNull);
      expect(updates['$summary/categories/3/txn-1'], isNull);

      /// and the old month's totals give the amount back.
      expect(updates['$day/day-finance-overview/expense'], increment(-200));
      expect(updates['$summary/month-finance-overview/expense'], increment(-200));
      expect(updates['$summary/month-finance-overview/balance'], increment(200));

      /// while the new month takes it on.
      expect(updates['$newDay/transactions/txn-1'], isNotNull);
      expect(updates['$newDay/day-finance-overview/expense'], increment(200));
      expect(updates['$newMonth/summary/month-finance-overview/expense'], increment(200));
      expect(updates['$newMonth/summary/month-finance-overview/balance'], increment(-200));
    });

    test('moving to another day in the same month keeps one month total', () {
      final updates = transactionWriteUpdates(
        previous: transaction(amount: 200, date: '12 04 2024'),
        next: transaction(amount: 200, date: '13 04 2024'),
      );

      /// the day totals move...
      expect(updates['$day/day-finance-overview/expense'], increment(-200));
      expect(updates['$month/day-wise-transactions/13/day-finance-overview/expense'],
          increment(200));

      /// ...but the month total nets to zero and is not written.
      expect(updates.containsKey('$summary/month-finance-overview/expense'), isFalse);
      expect(updates.containsKey('$summary/month-finance-overview/balance'), isFalse);
    });
  });

  group('path shape', () {
    test('keys are relative paths with no leading slash', () {
      final updates = transactionWriteUpdates(
        previous: transaction(),
        next: transaction(date: '03 05 2024'),
      );

      for (final key in updates.keys) {
        expect(key.startsWith('/'), isFalse,
            reason: '$key must be relative to the user transactions node');
      }
    });
  });
}
