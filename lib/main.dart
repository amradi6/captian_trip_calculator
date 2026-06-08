import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'firebase_options.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/trip_provider.dart';
import 'utils/app_theme.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/main_scaffold.dart';
import 'screens/trip_details/trip_details_screen.dart';
import 'screens/settings/app_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use legacy renderer on Android — prevents Vulkan crash on emulators
  // and older devices that don't support the new Maps renderer
  AndroidGoogleMapsFlutter.useAndroidViewSurface = false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appState = AppStateProvider();
  await appState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const CaptainApp(),
    ),
  );
}

class CaptainApp extends StatelessWidget {
  const CaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return MaterialApp(
      title: 'Captain Trip Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: appState.themeMode,
      locale: appState.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: appState.isAr ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/create-account':
            return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const MainScaffold());
          case '/trip-details':
            final tripId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => TripDetailsScreen(tripId: tripId),
            );
          case '/settings':
            return MaterialPageRoute(builder: (_) => const AppSettingsScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
