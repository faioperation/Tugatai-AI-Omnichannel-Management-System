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

  static String? get fcmToken => _preferences.getString('fcm_token');

  static Future<void> saveFcmToken(String token) async {
    await _preferences.setString('fcm_token', token);
  }

  static Future<void> saveSelectedBranch({required String id, required String name, required String address}) async {
    await _preferences.setString('selectedBranchId', id);
    await _preferences.setString('selectedBranchName', name);
    await _preferences.setString('selectedBranchAddress', address);
  }

  static Map<String, String>? get selectedBranch {
    final id = _preferences.getString('selectedBranchId');
    final name = _preferences.getString('selectedBranchName');
    final address = _preferences.getString('selectedBranchAddress');
    if (id != null && name != null) {
      return {'id': id, 'name': name, 'address': address ?? ''};
    }
    return null;
  }
}
