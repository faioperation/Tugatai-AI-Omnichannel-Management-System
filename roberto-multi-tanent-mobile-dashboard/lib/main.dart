import 'package:flutter/cupertino.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/app.dart';
import 'app/theme_controller.dart';

import 'package:roberto/core/services/local_storage_service.dart';
import 'package:roberto/core/services/firebase_messaging_service.dart';
void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  
  final initialThemeMode = await ThemeController.getStoredThemeMode();
  themeController = ThemeController(initialMode: initialThemeMode);
  
  await FirebaseMessagingService().init();
  
  runApp(const Roberto());
}
