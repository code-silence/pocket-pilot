import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';

class BudgetNotifier extends StateNotifier<Budget?> {
  BudgetNotifier() : super(null) {
    _loadBudget();
  }

  final Box<Budget> _box = Hive.box<Budget>('budgets');

  void _loadBudget() {
    final now = DateTime.now();
    final key = '${now.year}-${now.month}';
    state = _box.get(key);
  }

  void setBudget({required double monthlyLimit, required double savingsGoal}) {
    final now = DateTime.now();
    final key = '${now.year}-${now.month}';
    final budget = Budget(
      monthlyLimit: monthlyLimit,
      savingsGoal: savingsGoal,
      month: now.month,
      year: now.year,
    );
    _box.put(key, budget);
    state = budget;
  }

  void clearBudget() {
    final now = DateTime.now();
    final key = '${now.year}-${now.month}';
    _box.delete(key);
    state = null;
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, Budget?>((ref) {
  return BudgetNotifier();
});