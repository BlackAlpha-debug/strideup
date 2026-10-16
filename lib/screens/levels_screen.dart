import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/level_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen>
    with SingleTickerProviderStateMixin {
  static final _allLevelsReversed = LevelInfo.all.reversed.toList();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final levelProvider = context.watch<LevelProvider>();
    final allLevels = _allLevelsReversed;

    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -30,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.tertiaryFixedDim.withValues(alpha: 0.05),
            ),
          ),
        ),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            children: [
              Text('Your Journey', style: theme.textTheme.displayMedium)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                'Climb the ranks. Every step fuels your momentum.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 40,
                      bottom: 40,
                      child: Container(
                        width: 2,
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return Container(
                            width: 4,
                            height: 200 * value,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colors.primaryContainer,
                                  colors.secondaryFixed,
                                  colors.secondaryFixed.withValues(alpha: 0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primaryContainer.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    Column(
                      children: List.generate(allLevels.length, (index) {
                        final level = allLevels[index];
                        final status = levelProvider.levelStatus(level.level);
                        final isRight = index.isEven;
                        final delay = (index * 200).ms;

                        if (status == 'current') {
                          return _buildCurrentLevel(
                            level,
                            levelProvider,
                            colors,
                            theme,
                            delay,
                          );
                        }

                        return _buildLevelNode(
                          level,
                          status,
                          levelProvider.levelDate(level.level),
                          isRight,
                          colors,
                          theme,
                          delay,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelNode(
    LevelInfo level,
    String status,
    String? dateAchieved,
    bool isRight,
    AppColors colors,
    ThemeData theme,
    Duration delay,
  ) {
    final isLocked = status == 'locked';
    final opacity = isLocked ? 0.5 : 1.0;

    final content = Column(
      crossAxisAlignment: isRight
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Level ${level.level}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: isLocked ? colors.outlineVariant : colors.secondaryFixed,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          level.name,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: isLocked ? colors.onSurfaceVariant : colors.onSurface,
          ),
        ),
        if (dateAchieved != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Achieved $dateAchieved',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ),
      ],
    );

    final node = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked ? colors.surfaceContainerHigh : colors.surfaceContainer,
        border: Border.all(
          color: isLocked
              ? colors.outlineVariant.withValues(alpha: 0.2)
              : colors.secondaryFixed.withValues(alpha: 0.4),
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: colors.secondaryFixed.withValues(alpha: 0.15),
                  blurRadius: 15,
                ),
              ],
      ),
      child: Icon(
        isLocked ? Icons.lock : level.icon,
        color: isLocked ? colors.outlineVariant : colors.secondaryFixed,
        size: 24,
      ),
    );

    return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              children: [
                if (isRight) ...[
                  const Expanded(child: SizedBox()),
                  node,
                  const SizedBox(width: 16),
                  Expanded(child: content),
                ] else ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: content,
                    ),
                  ),
                  const SizedBox(width: 16),
                  node,
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: 500.ms)
        .slideX(
          begin: isRight ? 0.15 : -0.15,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildCurrentLevel(
    LevelInfo level,
    LevelProvider levelProvider,
    AppColors colors,
    ThemeData theme,
    Duration delay,
  ) {
    final progress = levelProvider.progress;
    final totalXP = levelProvider.totalXP;
    final nextLevelInfo = level.level < LevelInfo.all.length
        ? LevelInfo.all[level.level]
        : null;
    final targetXP = nextLevelInfo?.xpRequired ?? level.xpRequired;
    final xpToNext = levelProvider.xpToNext;

    return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainer,
                      border: Border.all(
                        color: colors.primaryContainer.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primaryContainer.withValues(
                            alpha: 0.15 + _pulseController.value * 0.1,
                          ),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 82,
                          height: 82,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOut,
                            builder: (context, value, _) {
                              return CustomPaint(
                                painter: _ProgressRingPainter(
                                  progress: value,
                                  startColor: colors.primaryContainer,
                                  endColor: colors.secondaryFixed,
                                  trackColor: colors.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(
                          level.icon,
                          color: colors.primaryContainer,
                          size: 36,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              GlassCard(
                borderRadius: 24,
                opacity: 0.4,
                blur: 30,
                color: colors.surfaceContainerHigh,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Level ${level.level}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primaryContainer,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondaryFixed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'CURRENT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.secondaryFixed,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(level.name, style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatNumber(totalXP),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${formatNumber(targetXP)} XP',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: value,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors.primaryContainer,
                                        colors.secondaryFixed,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.secondaryFixed.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 10,
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
                    const SizedBox(height: 12),
                    if (nextLevelInfo != null)
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Only '),
                            TextSpan(
                              text: '${formatNumber(xpToNext)} XP',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' to Level ${nextLevelInfo.level}!'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), delay: delay, duration: 600.ms);
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 3;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = trackColor;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [startColor, endColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
