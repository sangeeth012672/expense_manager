import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/theme.dart';
import '../models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_repository.dart';

class AuthRepository {
  final http.Client client;

  AuthRepository({required this.client});

  Future<AuthResponse> sendOtp(String phone) async {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/auth/send-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send OTP: ${response.statusCode}');
    }
  }

  Future<AuthResponse> createAccount(String phone, String nickname) async {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/auth/create-account/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'nickname': nickname}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create account: ${response.statusCode}');
    }
  }

  Future<void> saveTokenAndNickname(String token, String nickname, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('nickname', nickname);
    await prefs.setString('phone', phone);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nickname');
    await prefs.remove('phone');
    
    // Clear local data - REMOVED to persist data for user isolation
    // await DatabaseHelper.instance.clearAllData();
    await SettingsRepository().clearAllSettings();
  }
}
