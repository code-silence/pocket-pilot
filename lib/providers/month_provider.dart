import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthNotifier extends StateNotifier<DateTime> {
  MonthNotifier() : super(DateTime.now());

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void resetToCurrentMonth() {
    state = DateTime.now();
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return state.month == now.month && state.year == now.year;
  }
}

final monthProvider =
    StateNotifierProvider<MonthNotifier, DateTime>((ref) {
  return MonthNotifier();
});