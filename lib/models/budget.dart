import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  double monthlyLimit;

  @HiveField(1)
  double savingsGoal;

  @HiveField(2)
  int month;

  @HiveField(3)
  int year;

  Budget({
    required this.monthlyLimit,
    required this.savingsGoal,
    required this.month,
    required this.year,
  });
}