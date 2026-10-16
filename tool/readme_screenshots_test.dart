import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride_up/providers/level_provider.dart';
import 'package:stride_up/providers/location_provider.dart';
import 'package:stride_up/providers/step_provider.dart';
import 'package:stride_up/providers/theme_provider.dart';
import 'package:stride_up/providers/user_provider.dart';
import 'package:stride_up/services/auth_service.dart';
import 'package:stride_up/services/storage_service.dart';
import 'package:stride_up/theme/app_colors.dart';
import 'package:stride_up/widgets/bottom_nav_shell.dart';

String _day(DateTime date) =>
    'steps_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Future<void> _loadFont(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  await (FontLoader(
    family,
  )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}

String _firstExisting(Iterable<String?> candidates, String description) {
  for (final candidate in candidates.whereType<String>()) {
    if (File(candidate).existsSync()) return candidate;
  }
  throw StateError(
    'Could not find $description. Set README_FONT_PATH or FLUTTER_ROOT.',
  );
}

String _flutterRoot() {
  final configured = Platform.environment['FLUTTER_ROOT'];
  if (configured != null && Directory(configured).existsSync()) {
    return configured;
  }

  var directory = File(Platform.resolvedExecutable).parent;
  while (directory.parent.path != directory.path) {
    final marker = File(
      '${directory.path}${Platform.pathSeparator}bin${Platform.pathSeparator}'
      'cache${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
      'material_fonts${Platform.pathSeparator}MaterialIcons-Regular.otf',
    );
    if (marker.existsSync()) return directory.path;
    directory = directory.parent;
  }
  throw StateError('Could not locate Flutter. Set FLUTTER_ROOT.');
}

void main() {
  setUpAll(() async {
    await _loadFont(
      'ReadmeFont',
      _firstExisting([
        Platform.environment['README_FONT_PATH'],
        if (Platform.isWindows) r'C:\Windows\Fonts\segoeui.ttf',
        if (Platform.isLinux) '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
        if (Platform.isMacOS) '/System/Library/Fonts/Helvetica.ttc',
      ], 'README font'),
    );
    final flutterRoot = _flutterRoot();
    await _loadFont(
      'MaterialIcons',
      '$flutterRoot${Platform.pathSeparator}bin${Platform.pathSeparator}'
          'cache${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
          'material_fonts${Platform.pathSeparator}MaterialIcons-Regular.otf',
    );
  });

  testWidgets('generate README screenshots', (tester) async {
    tester.view.physicalSize = const Size(393, 873);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final values = <String, Object>{
      'step_counting': false,
      'push_notifications': false,
      'notification_prompted': true,
      'user_name': 'Stride User',
      'session_email': 'user@example.com',
      'step_goal': 10000,
      'total_steps': 28740,
      'streak': 4,
      for (var i = 0; i < 7; i++)
        _day(now.subtract(Duration(days: 6 - i))): [
          4210,
          6380,
          5120,
          7840,
          6930,
          8650,
          7234,
        ][i],
    };
    // The screenshot harness intentionally replaces device preferences.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(values);
    final storage = StorageService();
    await storage.init();
    final baseTheme = ThemeData.dark();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService(storage: storage)),
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(storage: storage),
          ),
          ChangeNotifierProvider(create: (_) => StepProvider(storage: storage)),
          ChangeNotifierProvider(
            create: (_) => LocationProvider(storage: storage)..init(),
          ),
          ChangeNotifierProvider(
            create: (_) => LevelProvider(storage: storage)..init(),
          ),
          ChangeNotifierProvider(
            create: (_) => UserProvider(storage: storage)..init(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme.apply(fontFamily: 'ReadmeFont'),
            primaryTextTheme: baseTheme.primaryTextTheme.apply(
              fontFamily: 'ReadmeFont',
            ),
            extensions: [const AppColors()],
          ),
          home: const BottomNavShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../docs/images/home.png'),
    );

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../docs/images/stats.png'),
    );

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../docs/images/profile.png'),
    );
  });
}
