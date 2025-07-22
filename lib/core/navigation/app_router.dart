import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/meetings/presentation/pages/join_meeting_page.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String createMeeting = '/create-meeting';
  static const String joinMeeting = '/join-meeting';
  static const String meeting = '/meeting';
  static const String profile = '/profile';
}

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Home Routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Meeting Routes
      GoRoute(
        path: AppRoutes.createMeeting,
        name: 'create-meeting',
        builder: (context, state) =>
            const Placeholder(), // Will be replaced with CreateMeetingScreen
      ),

      GoRoute(
        path: AppRoutes.joinMeeting,
        name: 'join-meeting',
        builder: (context, state) => const JoinMeetingPage(),
      ),

      GoRoute(
        path: '${AppRoutes.meeting}/:meetingId',
        name: 'meeting',
        builder: (context, state) {
          final meetingId = state.pathParameters['meetingId']!;
          return Placeholder(
            child: Text('Meeting: $meetingId'),
          ); // Will be replaced with MeetingScreen
        },
      ),

      // Profile Route
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) =>
            const Placeholder(), // Will be replaced with ProfileScreen
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Navigation helper methods
class AppNavigation {
  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  static void goToRegister(BuildContext context) {
    context.go(AppRoutes.register);
  }

  static void goToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void goToCreateMeeting(BuildContext context) {
    context.go(AppRoutes.createMeeting);
  }

  static void goToJoinMeeting(BuildContext context) {
    context.go(AppRoutes.joinMeeting);
  }

  static void goToMeeting(BuildContext context, String meetingId) {
    context.go('${AppRoutes.meeting}/$meetingId');
  }

  static void goToProfile(BuildContext context) {
    context.go(AppRoutes.profile);
  }

  static void goBack(BuildContext context) {
    context.pop();
  }

  static void pushToLogin(BuildContext context) {
    context.push(AppRoutes.login);
  }

  static void pushToRegister(BuildContext context) {
    context.push(AppRoutes.register);
  }

  static void pushToProfile(BuildContext context) {
    context.push(AppRoutes.profile);
  }
}
