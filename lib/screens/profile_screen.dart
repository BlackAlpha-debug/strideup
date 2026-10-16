import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../providers/level_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/location_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showMeasurementsDialog() async {
    final user = context.read<UserProvider>();
    final steps = context.read<StepProvider>();
    final weight = TextEditingController(
      text: user.weightKg.toStringAsFixed(1),
    );
    final stride = TextEditingController(
      text: user.stepLengthCm.toStringAsFixed(1),
    );
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Fitness estimates'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
              TextField(
                controller: stride,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Step length (cm)',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Used only for estimated distance and active calories.',
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await user.updateMeasurements(
                    weightKg: double.parse(weight.text),
                    stepLengthCm: double.parse(stride.text),
                  );
                  await steps.refreshPreferences();
                  if (context.mounted) Navigator.pop(context);
                } catch (_) {
                  setDialogState(
                    () => error =
                        'Enter weight 20–350 kg and step length 20–150 cm.',
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    weight.dispose();
    stride.dispose();
  }

  void _showTrackingModeSheet() {
    var draftSensitivity = context.read<StepProvider>().sensitivity;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Consumer<StepProvider>(
          builder: (context, steps, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step sensitivity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: steps.trackingMode,
                  onChanged: (value) {
                    if (value != null) steps.updateTrackingMode(value);
                  },
                  child: const Column(
                    children: [
                      RadioListTile(
                        value: 'battery',
                        title: Text('Battery saver'),
                        subtitle: Text(
                          'Accurate cumulative sensor; updates can take up to 10 seconds.',
                        ),
                      ),
                      RadioListTile(
                        value: 'responsive',
                        title: Text('Responsive'),
                        subtitle: Text(
                          'Per-step hardware detector with cumulative correction.',
                        ),
                      ),
                      RadioListTile(
                        value: 'sensitive',
                        title: Text('High sensitivity'),
                        subtitle: Text(
                          'Also detects softer motion. Uses more battery and may count some false steps.',
                        ),
                      ),
                    ],
                  ),
                ),
                if (steps.trackingMode == 'sensitive') ...[
                  const SizedBox(height: 4),
                  Text('Sensitivity ${(draftSensitivity * 100).round()}%'),
                  Slider(
                    value: draftSensitivity,
                    min: .35,
                    max: 1.2,
                    onChanged: (value) =>
                        setSheetState(() => draftSensitivity = value),
                    onChangeEnd: (value) => steps.updateTrackingMode(
                      'sensitive',
                      sensitivity: value,
                    ),
                  ),
                ],
                if (steps.sensorMode.isNotEmpty)
                  Text('Active sensor: ${steps.sensorMode}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    final userProvider = context.read<UserProvider>();
    final controller = TextEditingController(text: userProvider.name);
    final colors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Edit Name', style: Theme.of(ctx).textTheme.titleLarge),
        content: Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            style: Theme.of(ctx).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                userProvider.updateName(newName);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colors.primaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => Consumer<StepProvider>(
        builder: (context, steps, _) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step notification',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('${formatNumber(steps.todaySteps)} steps today'),
                Text('${steps.calories.round()} kcal estimated'),
                const SizedBox(height: 12),
                Text(steps.statusText),
                const SizedBox(height: 12),
                const Text(
                  'Use the switches in Profile to manage the live notification and step counting.',
                ),
                TextButton(
                  onPressed: steps.openSettings,
                  child: const Text('Android notification settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -60,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.tertiaryContainer.withValues(alpha: 0.04),
            ),
          ),
        ),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors, theme),
              const SizedBox(height: 32),
              _buildQuickStats(colors, theme),
              const SizedBox(height: 32),
              _buildGoalsSection(colors, theme),
              const SizedBox(height: 24),
              _buildPreferencesSection(colors, theme),
              const SizedBox(height: 24),
              _buildAccountSection(colors, theme),
              const SizedBox(height: 32),
              _buildVersionFooter(colors, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppColors colors, ThemeData theme) {
    final userProvider = context.watch<UserProvider>();
    final levelProvider = context.watch<LevelProvider>();

    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primaryContainer.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.background,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/Stride Up.png',
                                width: 106,
                                height: 106,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 14,
                                  color: colors.secondaryFixed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Level ${levelProvider.currentLevel.level}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _showEditNameDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            userProvider.name,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.watch<AuthService>().userEmail ?? 'Local profile',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.95, 0.95), duration: 500.ms),
      ],
    );
  }

  Widget _buildQuickStats(AppColors colors, ThemeData theme) {
    final stepProvider = context.watch<StepProvider>();
    final levelProvider = context.watch<LevelProvider>();

    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildStatColumn(
                formatCompactNumber(stepProvider.totalSteps),
                'Total Steps',
                colors,
                theme,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(
              child: _buildStatColumn(
                '${levelProvider.streak}',
                'Day Streak',
                colors,
                theme,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildStatColumn(
    String value,
    String label,
    AppColors colors,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildGoalsSection(AppColors colors, ThemeData theme) {
    final userProvider = context.watch<UserProvider>();

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('DAILY GOALS', style: theme.textTheme.labelSmall),
            ),
            const SizedBox(height: 12),
            GlassCard(
              borderRadius: 24,
              opacity: 0.35,
              blur: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step Goal',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                Text(
                                  formatNumber(userProvider.stepGoal),
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: colors.primaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'steps',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryContainer.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primaryContainer.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_run,
                          color: colors.primaryContainer,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: colors.primaryContainer,
                      inactiveTrackColor: colors.surfaceContainerHighest,
                      thumbColor: Colors.white,
                      overlayColor: colors.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                      thumbShape: _GlowThumbShape(
                        glowColor: colors.primaryContainer,
                      ),
                      trackHeight: 6,
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: userProvider.stepGoal.toDouble(),
                      min: 2000,
                      max: 20000,
                      divisions: 36,
                      onChanged: (v) {
                        userProvider.updateStepGoal(v.round());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2K',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '20K',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildPreferencesSection(AppColors colors, ThemeData theme) {
    final userProvider = context.watch<UserProvider>();
    final steps = context.watch<StepProvider>();

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('PREFERENCES', style: theme.textTheme.labelSmall),
            ),
            const SizedBox(height: 12),
            GlassCard(
              borderRadius: 24,
              opacity: 0.25,
              blur: 15,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildToggleRow(
                    Icons.my_location,
                    'Location Tracking',
                    'For accurate route mapping',
                    userProvider.locationTracking,
                    (v) {
                      userProvider.setLocationTracking(v);
                      if (!v) context.read<LocationProvider>().stopTracking();
                    },
                    colors,
                    theme,
                  ),
                  _divider(colors),
                  _buildToggleRow(
                    Icons.notifications_active,
                    'Step notification',
                    'Live steps & calories. Off: count only with app open.',
                    steps.notificationsEnabled,
                    steps.busy || !steps.supported
                        ? null
                        : steps.setNotificationsEnabled,
                    colors,
                    theme,
                  ),
                  _divider(colors),
                  _buildToggleRow(
                    Icons.directions_walk,
                    'Step counting',
                    'Off: stop the step sensor and notification to save battery.',
                    steps.countingEnabled,
                    steps.busy || !steps.supported
                        ? null
                        : steps.setCountingEnabled,
                    colors,
                    theme,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps.statusText,
                          style: theme.textTheme.bodySmall,
                        ),
                        if (steps.permissionDenied ||
                            (steps.notificationsEnabled &&
                                !steps.notificationGranted))
                          TextButton(
                            onPressed: steps.openSettings,
                            child: const Text('Android permissions'),
                          ),
                      ],
                    ),
                  ),
                  _divider(colors),
                  _buildNavRow(
                    Icons.straighten,
                    'Distance Unit',
                    userProvider.useKilometers ? 'Kilometers' : 'Miles',
                    () => userProvider.toggleUnits(),
                    colors,
                    theme,
                  ),
                  _divider(colors),
                  _buildNavRow(
                    Icons.monitor_weight_outlined,
                    'Weight & step length',
                    '${userProvider.weightKg.toStringAsFixed(0)} kg · ${userProvider.stepLengthCm.toStringAsFixed(0)} cm',
                    _showMeasurementsDialog,
                    colors,
                    theme,
                  ),
                  _divider(colors),
                  _buildNavRow(
                    Icons.speed,
                    'Step sensitivity',
                    steps.trackingMode == 'sensitive'
                        ? 'High'
                        : steps.trackingMode == 'battery'
                        ? 'Battery'
                        : 'Responsive',
                    _showTrackingModeSheet,
                    colors,
                    theme,
                  ),
                  _divider(colors),
                  _buildNavRow(
                    Icons.notifications_outlined,
                    'View Notifications',
                    '',
                    _showNotificationsSheet,
                    colors,
                    theme,
                  ),
                  _divider(colors),
                  _buildThemeRow(colors, theme),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildToggleRow(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
    AppColors colors,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _iconCircle(icon, colors),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: colors.primaryContainer,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colors.surfaceContainerHighest,
            trackOutlineColor: WidgetStateProperty.all(
              Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(
    IconData icon,
    String title,
    String currentValue,
    VoidCallback onTap,
    AppColors colors,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _iconCircle(icon, colors),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Text(title, style: theme.textTheme.bodyLarge),
            ),
            if (currentValue.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Text(
                  currentValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.primaryContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeRow(AppColors colors, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _iconCircle(Icons.dark_mode, colors),
          const SizedBox(width: 16),
          Expanded(child: Text('App Theme', style: theme.textTheme.bodyLarge)),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _themeChip('Light', 0, colors, theme),
                _themeChip('Dark', 1, colors, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeChip(
    String label,
    int index,
    AppColors colors,
    ThemeData theme,
  ) {
    final themeProvider = context.watch<ThemeProvider>();
    final isActive = index == 0 ? !themeProvider.isDark : themeProvider.isDark;
    return GestureDetector(
      onTap: () {
        themeProvider.setThemeMode(
          index == 0 ? ThemeMode.light : ThemeMode.dark,
        );
        context.read<StepProvider>().setAccent(
          index == 0 ? 0xFF00BCD4 : 0xFF00F2FF,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? colors.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: Colors.white.withValues(alpha: 0.05))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? colors.primaryContainer : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(AppColors colors, ThemeData theme) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('ACCOUNT', style: theme.textTheme.labelSmall),
            ),
            const SizedBox(height: 12),
            GlassCard(
              borderRadius: 20,
              opacity: 0.25,
              blur: 15,
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: context.read<StepProvider>().openSettings,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          color: colors.onSurfaceVariant,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Health Data Permissions',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final auth = context.read<AuthService>();
                      final location = context.read<LocationProvider>();
                      final steps = context.read<StepProvider>();
                      await location.stopTracking();
                      await steps.stopForLogout();
                      await auth.logout();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: colors.error, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildVersionFooter(AppColors colors, ThemeData theme) {
    final steps = context.watch<StepProvider>();
    return Center(
      child: Text(
        'StrideUp v${steps.appVersion} (Build ${steps.buildNumber})',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _iconCircle(IconData icon, AppColors colors) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surfaceContainerHighest,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, size: 20, color: colors.onSurface),
    );
  }

  Widget _divider(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
    );
  }
}

class _GlowThumbShape extends SliderComponentShape {
  final Color glowColor;

  const _GlowThumbShape({required this.glowColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = glowColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(center, 3, Paint()..color = glowColor);
  }
}
