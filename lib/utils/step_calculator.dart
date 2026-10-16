import '../models/level_data.dart';

// Approximate active energy for level walking, excluding resting metabolism.
// Horizontal walking cost: 0.1 ml O2/kg/m * ~5 kcal/litre = 0.5 kcal/kg/km.
double stepsToCalories(
  int steps, {
  double weightKg = 70,
  double strideM = 0.762,
}) {
  return stepsToDistanceKm(steps, strideM: strideM) * weightKg * 0.5;
}

double stepsToDistanceKm(int steps, {double strideM = 0.762}) {
  return steps * strideM / 1000;
}

double stepsToDistanceMi(int steps, {double strideM = 0.762}) {
  return stepsToDistanceKm(steps, strideM: strideM) * 0.621371;
}

int stepsToXP(int steps) {
  return (steps / 100).floor();
}

int stepsToActiveMinutes(int steps) {
  return (steps / 100).round();
}

({LevelInfo current, double progress, int xpToNext}) levelFromTotalSteps(
  int totalSteps,
) {
  final xp = stepsToXP(totalSteps);
  final levels = LevelInfo.all;

  for (int i = levels.length - 1; i >= 0; i--) {
    if (xp >= levels[i].xpRequired) {
      final current = levels[i];
      final nextXP = i < levels.length - 1
          ? levels[i + 1].xpRequired
          : current.xpRequired;
      final range = nextXP - current.xpRequired;
      final progress = range > 0
          ? ((xp - current.xpRequired) / range).clamp(0.0, 1.0)
          : 1.0;
      final xpToNext = nextXP - xp;
      return (
        current: current,
        progress: progress,
        xpToNext: xpToNext > 0 ? xpToNext : 0,
      );
    }
  }

  return (
    current: levels.first,
    progress: 0.0,
    xpToNext: levels.first.xpRequired,
  );
}
