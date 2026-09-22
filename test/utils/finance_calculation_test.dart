import 'package:expense_tracker/modals/firebase_modal/day_finance_overview_modal.dart';
import 'package:expense_tracker/modals/firebase_modal/month_finance_overview_modal.dart';
import 'package:expense_tracker/modals/firebase_modal/transaction_modal.dart';
import 'package:expense_tracker/utils/finance_calculation.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Transactions are stored with a `'DD MM YYYY'` date string; only the amount,
/// type and date matter to the arithmetic under test.
TransactionModal transaction({
  required int amount,
  required TransactionType type,
  String date = '12 04 2024',
}) {
  return TransactionModal(
    id: 'test-id',
    amount: amount,
    transactionType: type.index,
    transactionMode: TransactionMode.cash.index,
    category: 0,
    date: date,
    time: 0,
    description: null,
    location: null,
    imageUrl: null,
  );
}

void main() {
  group('parseTransactionDate', () {
    test('splits a stored date into day, month and year', () {
      final parsed = parseTransactionDate('12 04 2024');

      expect(parsed.day, '12');
      expect(parsed.month, '04');
      expect(parsed.year, '2024');
    });

    test('builds the MM-YYYY key used for month-wise-transactions nodes', () {
      expect(parseTransactionDate('12 04 2024').monthKey, '04-2024');
    });
  });

  group('dayOverviewAfterAdding', () {
    test('an expense increases expense and leaves income untouched', () {
      final result = dayOverviewAfterAdding(
        DayFinanceOverviewModal(expense: 500, income: 900),
        transaction(amount: 200, type: TransactionType.expense),
      );

      expect(result.expense, 700);
      expect(result.income, 900);
    });

    test('an income increases income and leaves expense untouched', () {
      final result = dayOverviewAfterAdding(
        DayFinanceOverviewModal(expense: 500, income: 900),
        transaction(amount: 200, type: TransactionType.income),
      );

      expect(result.expense, 500);
      expect(result.income, 1100);
    });
  });

  group('dayOverviewAfterRemoving', () {
    test('an expense decreases expense and leaves income untouched', () {
      final result = dayOverviewAfterRemoving(
        DayFinanceOverviewModal(expense: 500, income: 900),
        transaction(amount: 200, type: TransactionType.expense),
      );

      expect(result.expense, 300);
      expect(result.income, 900);
    });

    test('an income decreases income and leaves expense untouched', () {
      final result = dayOverviewAfterRemoving(
        DayFinanceOverviewModal(expense: 500, income: 900),
        transaction(amount: 200, type: TransactionType.income),
      );

      expect(result.expense, 500);
      expect(result.income, 700);
    });

    test('removing the only transaction of a day zeroes that side', () {
      final result = dayOverviewAfterRemoving(
        DayFinanceOverviewModal(expense: 200, income: 0),
        transaction(amount: 200, type: TransactionType.expense),
      );

      expect(result.expense, 0);
      expect(result.income, 0);
    });
  });

  group('monthOverviewAfterRemoving', () {
    test('an expense decreases expense and raises the balance', () {
      final result = monthOverviewAfterRemoving(
        FinanceOverviewModal(budget: 1000, expense: 800, income: 200, balance: 400, isSurpassed: false),
        transaction(amount: 300, type: TransactionType.expense),
      );

      expect(result.expense, 500);
      expect(result.income, 200);
      expect(result.budget, 1000);
      expect(result.balance, 700);
    });

    test('an income decreases income and lowers the balance', () {
      final result = monthOverviewAfterRemoving(
        FinanceOverviewModal(budget: 1000, expense: 800, income: 200, balance: 400, isSurpassed: false),
        transaction(amount: 200, type: TransactionType.income),
      );

      expect(result.expense, 800);
      expect(result.income, 0);
      expect(result.balance, 200);
    });

    test('flags isSurpassed when removing income pushes the balance negative', () {
      final result = monthOverviewAfterRemoving(
        FinanceOverviewModal(budget: 0, expense: 500, income: 600, balance: 100, isSurpassed: false),
        transaction(amount: 600, type: TransactionType.income),
      );

      expect(result.balance, -500);
      expect(result.isSurpassed, isTrue);
    });

    test('clears isSurpassed when removing an expense restores a positive balance', () {
      final result = monthOverviewAfterRemoving(
        FinanceOverviewModal(budget: 0, expense: 900, income: 400, balance: -500, isSurpassed: true),
        transaction(amount: 900, type: TransactionType.expense),
      );

      expect(result.balance, 400);
      expect(result.isSurpassed, isFalse);
    });
  });

  group('monthOverviewAfterAdding', () {
    test('an expense increases expense and lowers the balance', () {
      final result = monthOverviewAfterAdding(
        FinanceOverviewModal(budget: 1000, expense: 200, income: 0, balance: 800, isSurpassed: false),
        transaction(amount: 300, type: TransactionType.expense),
      );

      expect(result.expense, 500);
      expect(result.balance, 500);
      expect(result.isSurpassed, isFalse);
    });

    test('flags isSurpassed when an expense exceeds budget plus income', () {
      final result = monthOverviewAfterAdding(
        FinanceOverviewModal(budget: 100, expense: 0, income: 0, balance: 100, isSurpassed: false),
        transaction(amount: 250, type: TransactionType.expense),
      );

      expect(result.balance, -150);
      expect(result.isSurpassed, isTrue);
    });

    test('a balance of exactly zero is not surpassed', () {
      final result = monthOverviewAfterAdding(
        FinanceOverviewModal(budget: 100, expense: 0, income: 0, balance: 100, isSurpassed: false),
        transaction(amount: 100, type: TransactionType.expense),
      );

      expect(result.balance, 0);
      expect(result.isSurpassed, isFalse);
    });
  });
}
