import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../models/level_data.dart';
import '../providers/level_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/step_ring.dart';
import '../widgets/stat_tile.dart';
import '../utils/units.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final stepProvider = context.watch<StepProvider>();
    final levelProvider = context.watch<LevelProvider>();
    final userProvider = context.watch<UserProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          if (stepProvider.countingEnabled &&
              !stepProvider.hasPermission &&
              !stepProvider.permissionDenied)
            _buildPermissionBanner(context, stepProvider, colors, theme),
          if (stepProvider.permissionDenied)
            _buildDeniedBanner(context, stepProvider, colors, theme),

          if (!stepProvider.countingEnabled || stepProvider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                stepProvider.statusText,
                style: theme.textTheme.bodyMedium,
              ),
            ),

          const SizedBox(height: 16),
          RepaintBoundary(
            child: Animate(
              effects: [
                FadeEffect(duration: 600.ms),
                ScaleEffect(
                  begin: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
              ],
              child: StepRing(
                currentSteps: stepProvider.todaySteps,
                goalSteps: userProvider.stepGoal,
              ),
            ),
          ),

          const SizedBox(height: 32),

          _buildLevelCard(context, colors, theme, levelProvider)
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),

          const SizedBox(height: 24),

          RepaintBoundary(
            child: _buildStatGrid(
              context,
              colors,
              theme,
              stepProvider,
              userProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    StepProvider stepProvider,
    AppColors colors,
    ThemeData theme,
  ) {
    return GlassCard(
      borderRadius: 16,
      opacity: 0.4,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.directions_walk, color: colors.primaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enable step counting to track your activity',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => stepProvider.requestPermission(),
            child: Text(
              'Enable',
              style: TextStyle(color: colors.primaryContainer),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildDeniedBanner(
    BuildContext context,
    StepProvider stepProvider,
    AppColors colors,
    ThemeData theme,
  ) {
    return GlassCard(
      borderRadius: 16,
      opacity: 0.4,
      color: colors.error.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: colors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Step counting permission denied. Open Settings to enable.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => stepProvider.openSettings(),
            child: Text('Settings', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildLevelCard(
    BuildContext context,
    AppColors colors,
    ThemeData theme,
    LevelProvider levelProvider,
  ) {
    final level = levelProvider.currentLevel;
    final nextLevel = level.level < LevelInfo.all.length
        ? level.level + 1
        : level.level;

    return GlassCard(
      borderRadius: 20,
      opacity: 0.35,
      color: colors.surfaceContainerLow,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.military_tech,
                      color: colors.secondaryFixed,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Level ${level.level} — ${level.name}',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryFixed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.secondaryFixed.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: colors.secondaryFixed,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${levelProvider.streak} Day Streak',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.secondaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: levelProvider.progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.secondaryFixedDim,
                              colors.secondaryFixed,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: colors.secondaryFixed.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${levelProvider.totalXP} XP',
                style: theme.textTheme.bodyMedium,
              ),
              Flexible(
                child: Text(
                  '${levelProvider.xpToNext} XP to Lvl $nextLevel',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(
    BuildContext context,
    AppColors colors,
    ThemeData theme,
    StepProvider stepProvider,
    UserProvider userProvider,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child:
                    StatTile(
                          label: 'Calories',
                          value: '${stepProvider.calories.round()}',
                          unit: 'kcal',
                          icon: Icons.local_fire_department,
                          iconColor: colors.error,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.2, duration: 500.ms),
              ),
              const SizedBox(width: 16),
              Expanded(
                child:
                    StatTile(
                          label: 'Distance',
                          value: displayDistance(
                            stepProvider.distanceKm,
                            userProvider.useKilometers,
                          ).toStringAsFixed(1),
                          unit: distanceUnit(userProvider.useKilometers),
                          icon: Icons.straighten,
                          iconColor: colors.tertiaryFixedDim,
                        )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.2, duration: 500.ms),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child:
              StatTile(
                    label: 'Active Time',
                    value: '${stepProvider.activeMinutes}',
                    unit: 'min',
                    icon: Icons.timer,
                    iconColor: colors.primaryFixed,
                    trailing: _buildMiniBarChart(colors),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.2, duration: 500.ms),
        ),
      ],
    );
  }

  static const _barHeights = [0.3, 0.5, 1.0, 0.75, 0.4];

  Widget _buildMiniBarChart(AppColors colors) {
    final heights = _barHeights;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(heights.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(left: 3),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: heights[i] * 32),
            duration: Duration(milliseconds: 800 + i * 100),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return Container(
                width: 6,
                height: value,
                decoration: BoxDecoration(
                  color: colors.primaryFixed.withValues(
                    alpha: 0.3 + heights[i] * 0.7,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: heights[i] == 1.0
                      ? [
                          BoxShadow(
                            color: colors.primaryFixed.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
