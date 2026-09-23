class DayFinanceOverviewModal {
  final int expense;
  final int income;

  DayFinanceOverviewModal({
    required this.expense,
    required this.income,
  });

  Map<String, dynamic> toMap() {
    return {
      'expense': expense,
      'income': income,
    };
  }

  /// Missing or non-numeric fields read as 0, for the same reason as
  /// [FinanceOverviewModal.fromMap]: increments create only the keys they
  /// touch.
  factory DayFinanceOverviewModal.fromMap(Map<String, dynamic> map) {
    return DayFinanceOverviewModal(
      expense: _asInt(map['expense']),
      income: _asInt(map['income']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
