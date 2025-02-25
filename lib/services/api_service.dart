// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = "https://safealert.onrender.com/api";

  // GET request
  static Future<dynamic> get(String endpoint,
      {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: headers,
    );
    final jsonData = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw Exception(jsonData['message'] ?? 'API Error');
    }
  }

  // POST request
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      },
      body: jsonEncode(body),
    );
    final jsonData = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw Exception(jsonData['message'] ?? 'API Error');
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      },
      body: jsonEncode(body),
    );
    final jsonData = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonData;
    } else {
      throw Exception(jsonData['message'] ?? 'API Error');
    }
  }
}
