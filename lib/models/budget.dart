class Budget {
  final String eventId;
  final double totalBudget;
  double spentAmount;

  Budget({
    required this.eventId,
    required this.totalBudget,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => totalBudget - spentAmount;
}

class Expense {
  final String id;
  final String eventId;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.id,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
