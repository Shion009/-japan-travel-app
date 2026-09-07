import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/spot.dart';
import '../models/user.dart';

/// Points to the backend REST API.
/// - Production / APK release: https://japan-travel-api.onrender.com
/// - Web / Chrome: dynamically connects to the current web host on port 4000 (e.g. http://localhost:4000)
/// - Android emulator: uses http://10.0.2.2:4000
/// - Desktop / Windows / iOS: uses http://localhost:4000
/// - Can be overridden with --dart-define=API_BASE_URL=http://...
class ApiService {
  /// URL ของ Render backend (production)
  static const String _renderUrl = 'https://japan-travel-api.onrender.com';

  static String get baseUrl {
    // 1. ถ้า build ด้วย --dart-define=API_BASE_URL=... ให้ใช้ค่านั้นก่อนเลย
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // 2. ใน Flutter Web — ใช้ host ของหน้าเว็บปัจจุบัน (dev server)
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != '0.0.0.0') {
        return 'http://$host:4000';
      }
      return 'http://localhost:4000';
    }

    // 3. Android emulator — ชี้ไปที่ host machine
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // ถ้าเป็น release build ใช้ Render URL ทันที
      const bool isRelease = bool.fromEnvironment('dart.vm.product');
      if (isRelease) return _renderUrl;
      return 'http://10.0.2.2:4000';
    }

    // 4. Desktop / iOS — localhost
    return 'http://localhost:4000';
  }

  Future<List<Region>> getRegions() async {
    final res = await http.get(Uri.parse('$baseUrl/api/regions'));
    _checkOk(res);
    final List data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => Region.fromJson(e)).toList();
  }

  Future<List<SpotCategory>> getCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/api/categories'));
    _checkOk(res);
    final List data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => SpotCategory.fromJson(e)).toList();
  }

  Future<List<Spot>> getSpots({
    String? region,
    String? category,
    String? search,
  }) async {
    final params = <String, String>{};
    if (region != null && region.isNotEmpty) params['region'] = region;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/api/spots').replace(queryParameters: params);
    final res = await http.get(uri);
    _checkOk(res);
    final List data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => Spot.fromJson(e)).toList();
  }

  Future<Spot> getSpot(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/spots/$id'));
    _checkOk(res);
    return Spot.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  // ---------- Auth endpoints ----------

  /// สมัครสมาชิกใหม่
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    _checkOk(res);
    return AuthResult.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  /// เข้าสู่ระบบ
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _checkOk(res);
    return AuthResult.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  /// ดึงข้อมูลผู้ใช้ปัจจุบัน
  Future<User> getMe(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    _checkOk(res);
    return User.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  void _checkOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = body['error'] ?? 'API error ${res.statusCode}';
      throw Exception(msg);
    }
  }
}
