import 'package:flutter/material.dart';
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

void main() {
  for (final inset in [24.0, 48.0, 72.0]) {
    testWidgets('Phone navigation clears $inset px system inset', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 873);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'step_counting': false});
      final storage = StorageService();
      await storage.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => StepProvider(storage: storage),
            ),
            ChangeNotifierProvider(
              create: (_) => LevelProvider(storage: storage)..init(),
            ),
            ChangeNotifierProvider(
              create: (_) => UserProvider(storage: storage)..init(),
            ),
            ChangeNotifierProvider(
              create: (_) => ThemeProvider(storage: storage),
            ),
            ChangeNotifierProvider(
              create: (_) => LocationProvider(storage: storage),
            ),
            ChangeNotifierProvider(
              create: (_) => AuthService(storage: storage),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(extensions: [const AppColors()]),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: EdgeInsets.only(top: 32, bottom: inset),
                viewPadding: EdgeInsets.only(top: 32, bottom: inset),
                textScaler: TextScaler.linear(inset == 72 ? 1.3 : 1),
              ),
              child: child!,
            ),
            home: const BottomNavShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final nav = tester.getRect(find.byType(NavigationBar));
      expect(nav.bottom, lessThanOrEqualTo(873 - inset - 12));
      for (final label in ['Home', 'Levels', 'Map', 'Stats', 'Profile']) {
        final target = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        );
        final rect = tester.getRect(target);
        expect(rect.bottom, lessThanOrEqualTo(nav.bottom));
        expect(rect.top, greaterThanOrEqualTo(nav.top));
      }
      expect(tester.takeException(), isNull);
      if (inset == 72) {
        for (final target in [
          (Icons.stairs_outlined, 'Levels'),
          (Icons.explore_outlined, 'Map'),
          (Icons.bar_chart_outlined, 'Stats'),
        ]) {
          await tester.tap(find.byIcon(target.$1));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(seconds: 2));
          expect(find.text(target.$2), findsWidgets);
          expect(tester.takeException(), isNull);
        }
      }
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('Step notification'), findsOneWidget);
      expect(find.text('Step counting'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
