import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/units.dart';
import '../widgets/glass_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _showBars = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showBars = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyChart(colors, theme)
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, duration: 500.ms),
          const SizedBox(height: 16),
          _buildSecondaryGrid(colors, theme),
          const SizedBox(height: 24),
          _buildPeakActivity(colors, theme),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AppColors colors, ThemeData theme) {
    final stepProvider = context.watch<StepProvider>();
    final weeklySteps = stepProvider.weeklySteps;
    final weeklyTotal = stepProvider.weeklyTotal;
    final trendPercent = stepProvider.weeklyTrendPercent;
    final dayLabels = stepProvider.weeklyDates.map(weekdayLabel).toList();
    final maxSteps = weeklySteps.isEmpty
        ? 1.0
        : weeklySteps
              .reduce((a, b) => a > b ? a : b)
              .toDouble()
              .clamp(1.0, double.infinity);

    return GlassCard(
      borderRadius: 32,
      opacity: 0.3,
      blur: 30,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_run,
                          size: 16,
                          color: colors.primaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'WEEKLY STEPS',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formatNumber(weeklyTotal),
                            style: theme.textTheme.displayMedium,
                          ),
                          TextSpan(
                            text: ' total',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.secondaryContainer.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.secondaryFixed.withValues(alpha: 0.15),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendPercent >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: colors.secondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendPercent >= 0 ? '+' : ''}$trendPercent% vs last',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.secondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          RepaintBoundary(
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxSteps * 1.15,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colors.surfaceContainerHighest,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          formatNumber(weeklySteps[group.x.toInt()]),
                          TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= dayLabels.length) {
                            return const SizedBox();
                          }
                          final isToday = idx == 6;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dayLabels[idx],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isToday
                                    ? colors.primaryContainer
                                    : colors.onSurfaceVariant,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final isToday = i == 6;
                    final targetValue = weeklySteps[i].toDouble();
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _showBars ? targetValue : 0,
                          width: 28,
                          borderRadius: BorderRadius.circular(14),
                          gradient: isToday
                              ? LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    colors.primaryFixed,
                                    colors.primaryContainer,
                                  ],
                                )
                              : null,
                          color: isToday
                              ? null
                              : colors.surfaceContainerHighest,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxSteps * 1.05,
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryGrid(AppColors colors, ThemeData theme) {
    final stepProvider = context.watch<StepProvider>();
    final user = context.watch<UserProvider>();

    return Row(
      children: [
        Expanded(
          child:
              _buildSparklineCard(
                    'Calories',
                    '${stepProvider.weeklyCaloriesAvg.round()}',
                    'Daily avg',
                    Icons.local_fire_department,
                    colors.error,
                    stepProvider.weeklySteps,
                    colors,
                    theme,
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.15, duration: 500.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _buildSparklineCard(
                    'Distance',
                    displayDistance(
                      stepProvider.weeklyDistanceKm,
                      user.useKilometers,
                    ).toStringAsFixed(1),
                    'This week',
                    Icons.route,
                    colors.tertiaryFixedDim,
                    stepProvider.weeklySteps,
                    colors,
                    theme,
                    unit: distanceUnit(user.useKilometers),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.15, duration: 500.ms),
        ),
      ],
    );
  }

  Widget _buildSparklineCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color accentColor,
    List<int> dataPoints,
    AppColors colors,
    ThemeData theme, {
    String? unit,
  }) {
    final maxVal = dataPoints.isEmpty
        ? 1
        : dataPoints.reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxVal == 0 ? 1.0 : maxVal.toDouble();
    final spots = List.generate(
      dataPoints.length,
      (i) =>
          FlSpot(i.toDouble(), (dataPoints[i] / normalizedMax * 30).toDouble()),
    );

    return GlassCard(
      borderRadius: 20,
      opacity: 0.25,
      blur: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: theme.textTheme.headlineLarge),
                if (unit != null) ...[
                  TextSpan(
                    text: ' $unit',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: spots.length >= 2
                ? LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      clipData: const FlClipData.all(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: accentColor,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              if (index == spots.length - 1) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: accentColor,
                                  strokeWidth: 0,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 0,
                                color: Colors.transparent,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accentColor.withValues(alpha: 0.3),
                                accentColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakActivity(AppColors colors, ThemeData theme) {
    final stepProvider = context.watch<StepProvider>();
    final todaySteps = stepProvider.todaySteps;

    final peakActivities = [
      {
        'title': 'Today\'s Steps',
        'time': 'All day',
        'steps': todaySteps,
        'icon': 'wb_sunny',
        'highlight': true,
      },
      {
        'title': 'Weekly Average',
        'time': 'Last 7 days',
        'steps': stepProvider.weeklyTotal > 0
            ? (stepProvider.weeklyTotal / 7).round()
            : 0,
        'icon': 'commute',
        'highlight': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Activity Summary', style: theme.textTheme.headlineLarge),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 28,
          opacity: 0.2,
          blur: 10,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: List.generate(peakActivities.length, (i) {
              final activity = peakActivities[i];
              final isHighlight = activity['highlight'] as bool;
              final isLast = i == peakActivities.length - 1;

              return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isHighlight
                                    ? colors.primaryContainer.withValues(
                                        alpha: 0.1,
                                      )
                                    : colors.surfaceContainerHighest,
                                border: isHighlight
                                    ? Border.all(
                                        color: colors.primaryContainer
                                            .withValues(alpha: 0.2),
                                      )
                                    : null,
                                boxShadow: isHighlight
                                    ? [
                                        BoxShadow(
                                          color: colors.primaryContainer
                                              .withValues(alpha: 0.2),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                activity['icon'] == 'wb_sunny'
                                    ? Icons.wb_sunny
                                    : Icons.commute,
                                size: 20,
                                color: isHighlight
                                    ? colors.primaryContainer
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['title'] as String,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    activity['time'] as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${formatNumber(activity['steps'] as int)} steps',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isHighlight
                                    ? colors.primaryContainer
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: (600 + i * 150).ms, duration: 400.ms)
                  .slideX(begin: 0.1, duration: 400.ms);
            }),
          ),
        ),
      ],
    );
  }
}
