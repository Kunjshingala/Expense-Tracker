class BudgetModal {
  final int budget;
  final int expense;
  final int income;
  final bool isSurpassed;

  BudgetModal({
    required this.budget,
    required this.expense,
    required this.income,
    required this.isSurpassed,
  });

  Map<String, dynamic> toMap() {
    return {
      'budget': budget,
      'expense': expense,
      'income': income,
      'isSurpassed': isSurpassed,
    };
  }

  factory BudgetModal.fromMap(Map<String, dynamic> map) {
    return BudgetModal(
      budget: map['budget'],
      expense: map['expense'],
      income: map['income'],
      isSurpassed: map['isSurpassed'],
    );
  }
}
