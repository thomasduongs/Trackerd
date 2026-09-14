import 'package:flutter/material.dart';
import 'package:trackerd_app/app/app.dart';
import 'package:trackerd_app/app/newsession/new_exercise_page.dart';
import 'package:trackerd_app/app/newsession/session_exercise.dart';
import 'package:trackerd_app/app/newsession/session_input.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const sessionInput = '/session/new';
  static const sessionExercise = '/session/exercises';
  static const newExercise = '/exercises/new';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.home => _pageRoute(
        settings: settings,
        builder: (_) => const Home(),
      ),
      AppRoutes.sessionInput => _pageRoute(
        settings: settings,
        builder: (_) => const SessionInput(),
      ),
      AppRoutes.sessionExercise => _pageRoute(
        settings: settings,
        builder: (_) => SessionExercise(
          muscleGroup: settings.arguments as String? ?? 'Misc.',
        ),
      ),
      AppRoutes.newExercise => _slideDownRoute(
        settings: settings,
        builder: (_) => const NewExercisePage(),
      ),
      _ => _pageRoute(
        settings: settings,
        builder: (_) => const _UnknownRoutePage(),
      ),
    };
  }

  static MaterialPageRoute<void> _pageRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }

  static PageRouteBuilder<void> _slideDownRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: const Center(child: Text('The requested page does not exist.')),
    );
  }
}
