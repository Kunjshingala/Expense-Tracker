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

  factory DayFinanceOverviewModal.fromMap(Map<String, dynamic> map) {
    return DayFinanceOverviewModal(
      expense: map['expense'],
      income: map['income'],
    );
  }
}
