import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../utils/formatters.dart';

class StepRing extends StatelessWidget {
  final int currentSteps;
  final int goalSteps;
  final bool animate;

  const StepRing({
    super.key,
    required this.currentSteps,
    required this.goalSteps,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final percent = (currentSteps / goalSteps).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 120,
      lineWidth: 14,
      percent: percent,
      animation: animate,
      animationDuration: 1500,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      linearGradient: LinearGradient(
        colors: [
          colors.primaryContainer,
          colors.primaryContainer.withValues(alpha: 0.7),
        ],
      ),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatNumber(currentSteps),
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '/ ${formatNumber(goalSteps)} steps',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
