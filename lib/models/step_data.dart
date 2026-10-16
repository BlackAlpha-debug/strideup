class StepData {
  final int steps;
  final double calories;
  final double distanceKm;
  final int activeMinutes;
  final DateTime date;

  const StepData({
    required this.steps,
    required this.calories,
    required this.distanceKm,
    required this.activeMinutes,
    required this.date,
  });

  StepData copyWith({
    int? steps,
    double? calories,
    double? distanceKm,
    int? activeMinutes,
    DateTime? date,
  }) {
    return StepData(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      date: date ?? this.date,
    );
  }
}
