import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/month_provider.dart';
import '../utils/constants.dart';

class MonthNavigator extends ConsumerWidget {
  const MonthNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(monthProvider);
    final notifier = ref.read(monthProvider.notifier);
    final isCurrentMonth = notifier.isCurrentMonth;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Previous month ──
          IconButton(
            onPressed: () => notifier.previousMonth(),
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          // ── Month label ──
          GestureDetector(
            onTap: isCurrentMonth
                ? null
                : () => notifier.resetToCurrentMonth(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentMonth
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMM yyyy').format(selectedMonth),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrentMonth
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                  if (!isCurrentMonth) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.refresh,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Next month ──
          IconButton(
            onPressed: isCurrentMonth
                ? null
                : () => notifier.nextMonth(),
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth
                  ? AppColors.accent.withValues(alpha: 0.4)
                  : AppColors.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}