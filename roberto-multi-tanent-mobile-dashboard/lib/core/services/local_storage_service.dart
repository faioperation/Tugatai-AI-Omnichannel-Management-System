import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _preferences.setString('accessToken', accessToken);
    await _preferences.setString('refreshToken', refreshToken);
  }

  static String? get accessToken => _preferences.getString('accessToken');
  static String? get refreshToken => _preferences.getString('refreshToken');

  static Future<void> clearTokens() async {
    await _preferences.remove('accessToken');
    await _preferences.remove('refreshToken');
  }
}
