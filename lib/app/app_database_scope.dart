import 'package:flutter/widgets.dart';
import 'package:trackerd_app/data/database/app_database.dart';

class AppDatabaseScope extends InheritedWidget {
  const AppDatabaseScope({
    super.key,
    required this.database,
    required super.child,
  });

  final AppDatabase database;

  static AppDatabase of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppDatabaseScope>();
    assert(scope != null, 'No AppDatabaseScope found above this context.');
    return scope!.database;
  }

  @override
  bool updateShouldNotify(AppDatabaseScope oldWidget) =>
      database != oldWidget.database;
}
