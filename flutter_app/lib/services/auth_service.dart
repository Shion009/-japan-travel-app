import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

/// AuthService — จัดการ session / token ของผู้ใช้
/// ใช้ SharedPreferences เก็บ token ไว้ข้ามการเปิด-ปิดแอป
class AuthService {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _emailKey = 'auth_email';
  static const _idKey = 'auth_id';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  /// โหลด session จาก SharedPreferences ตอนเปิดแอป
  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final id = prefs.getInt(_idKey);
    final username = prefs.getString(_usernameKey);
    final email = prefs.getString(_emailKey);

    if (token != null && id != null && username != null && email != null) {
      _token = token;
      _currentUser = User(id: id, username: username, email: email);
      return true;
    }
    return false;
  }

  /// บันทึก session หลัง login/register สำเร็จ
  Future<void> saveSession(AuthResult result) async {
    _token = result.token;
    _currentUser = result.user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, result.token);
    await prefs.setInt(_idKey, result.user.id);
    await prefs.setString(_usernameKey, result.user.username);
    await prefs.setString(_emailKey, result.user.email);
  }

  /// ล้าง session (Logout)
  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_idKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }

  /// ทดสอบว่า token ยังใช้งานได้ไหม
  Future<bool> verifyToken() async {
    if (_token == null) return false;
    try {
      await ApiService().getMe(_token!);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }
}
