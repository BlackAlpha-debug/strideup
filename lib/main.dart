import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/step_provider.dart';
import 'providers/location_provider.dart';
import 'providers/level_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'widgets/bottom_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(storage: storage)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage: storage)),
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
      child: const StrideUpApp(),
    ),
  );
}

class StrideUpApp extends StatelessWidget {
  const StrideUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = const AppTheme();
    final themeProvider = context.watch<ThemeProvider>();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: themeProvider.isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: themeProvider.isDark
            ? const Color(0xFF131313)
            : const Color(0xFFF5F5F5),
        systemNavigationBarIconBrightness: themeProvider.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'StrideUp',
      debugShowCheckedModeBanner: false,
      theme: appTheme.lightThemeData,
      darkTheme: appTheme.darkThemeData,
      themeMode: themeProvider.themeMode,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const BottomNavShell() : const LoginScreen();
        },
      ),
    );
  }
}
