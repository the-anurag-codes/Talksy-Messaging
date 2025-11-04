import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/bloc/chat_list_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/users/presentation/bloc/user_bloc.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<ChatListBloc>(create: (context) => di.sl<ChatListBloc>()),
        BlocProvider<ChatBloc>(create: (context) => di.sl<ChatBloc>()),
        BlocProvider<UsersBloc>(create: (context) => di.sl<UsersBloc>()),
      ],
      child: MaterialApp(
        title: 'Talksy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _minSplashTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    // Ensure splash screen shows for at least 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _minSplashTimeElapsed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthCheckComplete =
            state.status != AuthStatus.initial &&
            state.status != AuthStatus.loading;

        if (!_minSplashTimeElapsed || !isAuthCheckComplete) {
          return const SplashScreen();
        }

        // Show screen based on auth status
        if (state.status == AuthStatus.authenticated) {
          return const ChatListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
