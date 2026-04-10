import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  final Box<Expense> _box = Hive.box<Expense>('expenses');

  void _loadExpenses() {
    state = _box.values.toList().reversed.toList();
  }

  void addExpense(Expense expense) {
    _box.put(expense.id, expense);
    _loadExpenses();
  }

  void deleteExpense(String id) {
    _box.delete(id);
    _loadExpenses();
  }

  void updateExpense(Expense expense) {
    _box.put(expense.id, expense);
    _loadExpenses();
  }

  void deleteAll() {
    _box.clear();
    _loadExpenses();
  }

  double get totalSpent {
    return state.fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final e in state) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  List<Expense> get thisMonthExpenses {
    final now = DateTime.now();
    return state
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
  }

  Map<String, double> get thisMonthCategoryTotals {
    final Map<String, double> totals = {};
    for (final e in thisMonthExpenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  double get thisMonthTotal {
    return thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<int, double> get weeklyTotals {
    final Map<int, double> totals = {1: 0, 2: 0, 3: 0, 4: 0};
    for (final e in thisMonthExpenses) {
      final week = ((e.date.day - 1) / 7).floor() + 1;
      final clampedWeek = week.clamp(1, 4);
      totals[clampedWeek] = (totals[clampedWeek] ?? 0) + e.amount;
    }
    return totals;
  }

  // ── Insights helpers ──

  Map<String, double> get lastWeekTotals {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = weekStart.subtract(const Duration(days: 1));
    final Map<String, double> totals = {};
    for (final e in state) {
      if (e.date.isAfter(lastWeekStart) &&
          e.date.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  double get lastWeekTotal {
    return lastWeekTotals.values.fold(0.0, (sum, e) => sum + e);
  }

  double get thisWeekTotal {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return state
        .where(
          (e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  String get busiestDay {
    if (state.isEmpty) return 'N/A';
    final Map<String, double> dayTotals = {};
    for (final e in thisMonthExpenses) {
      final day = DateFormat('EEEE').format(e.date);
      dayTotals[day] = (dayTotals[day] ?? 0) + e.amount;
    }
    if (dayTotals.isEmpty) return 'N/A';
    return dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int get totalTransactionsThisMonth => thisMonthExpenses.length;

  // ── Selected month helpers ──
  List<Expense> expensesForMonth(DateTime month) {
    return state
        .where((e) => e.date.month == month.month && e.date.year == month.year)
        .toList();
  }

  double totalForMonth(DateTime month) {
    return expensesForMonth(month).fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> categoryTotalsForMonth(DateTime month) {
    final Map<String, double> totals = {};
    for (final e in expensesForMonth(month)) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Map<int, double> weeklyTotalsForMonth(DateTime month) {
    final Map<int, double> totals = {1: 0, 2: 0, 3: 0, 4: 0};
    for (final e in expensesForMonth(month)) {
      final week = ((e.date.day - 1) / 7).floor() + 1;
      final clampedWeek = week.clamp(1, 4);
      totals[clampedWeek] = (totals[clampedWeek] ?? 0) + e.amount;
    }
    return totals;
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((
  ref,
) {
  return ExpenseNotifier();
});
