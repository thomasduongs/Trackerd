import 'package:flutter/material.dart';
import 'package:trackerd_app/app/navigation/app_router.dart';
import 'package:trackerd_app/app/theme.dart';
import 'package:trackerd_app/app/app_database_scope.dart';
import 'package:trackerd_app/data/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(database: AppDatabase()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return AppDatabaseScope(
      database: database,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
