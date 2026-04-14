import 'package:flutter/material.dart';
import '../models/budget.dart';

class BudgetProvider with ChangeNotifier {
  final Map<String, Budget> _budgets = {
    'event_1': Budget(eventId: 'event_1', totalBudget: 50000, spentAmount: 15000),
    'event_2': Budget(eventId: 'event_2', totalBudget: 25000, spentAmount: 5000),
  };

  final List<Expense> _expenses = [
    Expense(
      id: 'e1',
      eventId: 'event_1',
      title: 'Venue Deposit',
      amount: 10000,
      date: DateTime.now(),
      category: 'Venue',
    ),
  ];

  Budget? getBudgetForEvent(String eventId) => _budgets[eventId];

  List<Expense> getExpensesForEvent(String eventId) {
    return _expenses.where((e) => e.eventId == eventId).toList();
  }

  void addExpense(String eventId, String title, double amount, String category) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      eventId: eventId,
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );
    _expenses.add(newExpense);
    
    if (_budgets.containsKey(eventId)) {
      _budgets[eventId]!.spentAmount += amount;
    }
    
    notifyListeners();
  }
}
