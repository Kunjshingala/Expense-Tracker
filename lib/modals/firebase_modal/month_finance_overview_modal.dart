class FinanceOverviewModal {
  final int budget;
  final int expense;
  final int income;
  final int balance;

  FinanceOverviewModal({
    required this.budget,
    required this.expense,
    required this.income,
    required this.balance,
  });

  /// Derived from [balance] rather than stored, so it can never drift out of
  /// step with the totals it describes. The month totals are written as
  /// server-side increments, which cannot maintain a boolean.
  bool get isSurpassed => balance < 0;

  Map<String, dynamic> toMap() {
    return {
      'budget': budget,
      'expense': expense,
      'income': income,
      'balance': balance,
    };
  }

  /// Missing or non-numeric fields read as 0. An overview node is created by
  /// the first increment written to it, so it legitimately may hold only the
  /// keys that have been touched so far.
  factory FinanceOverviewModal.fromMap(Map<String, dynamic> map) {
    return FinanceOverviewModal(
      budget: _asInt(map['budget']),
      expense: _asInt(map['expense']),
      income: _asInt(map['income']),
      balance: _asInt(map['balance']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
