import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// home
import 'package:blink/features/home/presentation/screens/home_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
  ],
);
