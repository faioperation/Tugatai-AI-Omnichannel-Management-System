import 'package:flutter/material.dart';
import '../features/Auth/screen/login_screen.dart';
import 'app_theme.dart';
import 'theme_controller.dart';
import 'app_routes.dart';


class Roberto extends StatelessWidget {
  const Roberto ({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: "TUGATAI",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          onGenerateRoute: Routes.generateRoute,
          initialRoute: Routes.login,
        );
      },
    );
  }
}