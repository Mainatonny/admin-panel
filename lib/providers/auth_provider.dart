import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _token;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get token => _token;

  // Base URL for API requests
  static const String _baseUrl = 'https://safealert.onrender.com/api/auth';

  Future<void> setAuthData(String userId, String token) async {
    try {
      _userId = userId;
      _token = token;
      _isAuthenticated = true;
      notifyListeners();

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('token', token);
    } catch (e) {
      throw Exception('Failed to save auth data: $e');
    }
  }

  Future<void> userLogin(String userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/login'), // User login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await setAuthData(responseData['userId'], responseData['token']);
      } else {
        throw Exception('User login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during user login: $e');
    }
  }

  Future<void> adminLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'), // Admin login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await setAuthData(responseData['userId'], responseData['token']);
      } else {
        throw Exception('Admin login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during admin login: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      _token = prefs.getString('token');
      _isAuthenticated = _userId != null && _token != null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to check login status: $e');
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await setAuthData(responseData['userId'], responseData['token']);
      } else {
        final errorMessage = responseData['message'] ??
            'Registration failed with status code ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error during registration: ${e.toString()}');
    }
  }

  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _isAuthenticated = false;
      _userId = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to clear auth data: $e');
    }
  }

  Future<void> logout() async {
    await clearAuthData();
  }

  Map<String, String> getAuthHeader() {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }
}
