import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/pages/login_page.dart';
import '../features/home/screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
