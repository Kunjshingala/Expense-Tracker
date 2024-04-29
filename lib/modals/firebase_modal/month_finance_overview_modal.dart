class FinanceOverviewModal {
  final int budget;
  final int expense;
  final int income;
  final int balance;
  final bool isSurpassed;

  FinanceOverviewModal({
    required this.budget,
    required this.expense,
    required this.income,
    required this.balance,
    required this.isSurpassed,
  });

  Map<String, dynamic> toMap() {
    return {
      'budget': budget,
      'expense': expense,
      'income': income,
      'balance': balance,
      'isSurpassed': isSurpassed,
    };
  }

  factory FinanceOverviewModal.fromMap(Map<String, dynamic> map) {
    return FinanceOverviewModal(
      budget: map['budget'],
      expense: map['expense'],
      income: map['income'],
      balance: map['balance'],
      isSurpassed: map['isSurpassed'],
    );
  }
}
