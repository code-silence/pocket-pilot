import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _monthlyReminder = false; // ← add this

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── Load saved settings ──
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _dailyReminder = prefs.getBool('daily_reminder_enabled') ?? false;
          final hour = prefs.getInt('reminder_hour') ?? 21;
          final minute = prefs.getInt('reminder_minute') ?? 0;
          _reminderTime = TimeOfDay(hour: hour, minute: minute);
          _monthlyReminder =
              prefs.getBool('monthly_reminder_enabled') ?? false; // ← add
        });
      }
    } catch (e) {
      // silently fails
    }
  }

  // ── Save settings ──
  Future<void> _saveSettings({
    required bool enabled,
    required TimeOfDay time,
    bool? monthlyEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', enabled);
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    if (monthlyEnabled != null) {
      await prefs.setBool('monthly_reminder_enabled', monthlyEnabled);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
      await _saveSettings(enabled: _dailyReminder, time: picked);
      if (_dailyReminder) {
        await NotificationService().scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder updated to ${picked.format(context)}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Daily reminder ──
            _sectionTitle('Daily Reminder'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log expense reminder',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Daily nudge to record expenses',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _dailyReminder,
                        activeColor: AppColors.primary,
                        onChanged: (val) async {
                          setState(() => _dailyReminder = val);
                          await _saveSettings(
                            enabled: val,
                            time: _reminderTime,
                          );
                          if (val) {
                            await NotificationService().scheduleDailyReminder(
                              hour: _reminderTime.hour,
                              minute: _reminderTime.minute,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Daily reminder enabled!'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          } else {
                            await NotificationService().cancelNotification(1);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Daily reminder disabled'),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  if (_dailyReminder) ...[
                    const Divider(height: 24),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reminder time',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _reminderTime.format(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Monthly summary ──
            _sectionTitle('Monthly Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly report reminder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Notified on 1st of every month',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_monthlyReminder) {
                        // disable
                        await NotificationService().cancelNotification(3);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('monthly_reminder_enabled', false);
                        setState(() => _monthlyReminder = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Monthly reminder disabled'),
                              backgroundColor: Colors.grey,
                            ),
                          );
                        }
                      } else {
                        // enable
                        await NotificationService().scheduleMonthlyReminder();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('monthly_reminder_enabled', true);
                        setState(() => _monthlyReminder = true);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Monthly reminder scheduled!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _monthlyReminder
                          ? Colors.grey
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(_monthlyReminder ? 'Disable' : 'Enable'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }
}
