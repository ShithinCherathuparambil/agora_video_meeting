import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const GooTeamStreamApp());
}

class GooTeamStreamApp extends StatelessWidget {
  const GooTeamStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: AuthRepository())
                ..add(const AuthStarted()),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

// Using SplashPage from features/splash/presentation/pages/splash_page.dart
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashPage();
  }
}
