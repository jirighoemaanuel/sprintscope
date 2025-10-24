import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/add_athlete_screen.dart';
import 'screens/coach_profile_screen.dart';
import 'screens/video_analysis_screen.dart';
import 'constants/theme.dart';
import 'providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'SprintScope',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            case '/dashboard':
              return MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              );
            case '/upload':
              return MaterialPageRoute(
                builder: (context) => const UploadScreen(),
              );
            case '/add-athlete':
              return MaterialPageRoute(
                builder: (context) => const AddAthleteScreen(),
              );
            case '/coach-profile':
              return MaterialPageRoute(
                builder: (context) => const CoachProfileScreen(),
              );
            case '/video-analysis':
              final args = settings.arguments as Map<String, dynamic>?;
              final video = args?['video'];
              if (video != null) {
                return MaterialPageRoute(
                  builder: (context) => VideoAnalysisScreen(video: video),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              );
            case '/auth':
              final args = settings.arguments as Map<String, dynamic>?;
              final isSignUp = args?['isSignUp'] ?? false;
              return MaterialPageRoute(
                builder: (context) => AuthScreen(isSignUp: isSignUp),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
              );
          }
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
