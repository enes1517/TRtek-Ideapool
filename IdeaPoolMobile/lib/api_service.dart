import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get defaultUrl {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux) {
      return "https://localhost:8443";
    } else {
      return "https://10.0.2.2:8443";
    }
  }

  static String baseUrl = defaultUrl;

  static http.Client get _client {
    if (kIsWeb) {
      return http.Client();
    } else {
      final ioClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return IOClient(ioClient);
    }
  }

  static String _buildUrl(String endpoint) {
    String cleanBase = baseUrl.trim();
    while (cleanBase.endsWith('/')) {
      cleanBase = cleanBase.substring(0, cleanBase.length - 1);
    }
    
    String cleanEndpoint = endpoint.trim();
    while (cleanEndpoint.startsWith('/')) {
      cleanEndpoint = cleanEndpoint.substring(1);
    }

    if (cleanBase.toLowerCase().endsWith(cleanEndpoint.toLowerCase())) {
      return cleanBase;
    }
    
    return "$cleanBase/$cleanEndpoint";
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> checkConnection() async {
    try {
      final client = _client;
      final targetUrl = _buildUrl("weatherforecast");
      final response = await client
          .get(Uri.parse(targetUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final client = _client;
      String targetUrl = _buildUrl(endpoint);
      
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(targetUrl).replace(queryParameters: queryParams);
        targetUrl = uri.toString();
      }
      
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse(targetUrl),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        String errMsg = response.body;
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['message'] != null) errMsg = errJson['message'];
        } catch (_) {}
        throw Exception(errMsg);
      }
    } catch (e) {
      throw Exception("Bağlantı Kurulamadı: $e");
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final client = _client;
      final targetUrl = _buildUrl(endpoint);
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse(targetUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return null;
      } else {
        String errMsg = response.body;
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['message'] != null) errMsg = errJson['message'];
        } catch (_) {}
        throw Exception(errMsg);
      }
    } catch (e) {
      throw Exception("Bağlantı Kurulamadı: $e");
    }
  }
  
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final client = _client;
      final targetUrl = _buildUrl(endpoint);
      final headers = await _getHeaders();
      final response = await client.put(
        Uri.parse(targetUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return null;
      } else {
        String errMsg = response.body;
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['message'] != null) errMsg = errJson['message'];
        } catch (_) {}
        throw Exception(errMsg);
      }
    } catch (e) {
      throw Exception("Bağlantı Kurulamadı: $e");
    }
  }

  static Future<dynamic> patch(String endpoint, [Map<String, dynamic>? data]) async {
    try {
      final client = _client;
      final targetUrl = _buildUrl(endpoint);
      final headers = await _getHeaders();
      final response = await client.patch(
        Uri.parse(targetUrl),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return null;
      } else {
        String errMsg = response.body;
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['message'] != null) errMsg = errJson['message'];
        } catch (_) {}
        throw Exception(errMsg);
      }
    } catch (e) {
      throw Exception("Bağlantı Kurulamadı: $e");
    }
  }

  static Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final client = _client;
      final targetUrl = _buildUrl(endpoint);
      final headers = await _getHeaders();
      
      final request = http.Request('DELETE', Uri.parse(targetUrl));
      request.headers.addAll(headers);
      if (data != null) {
        request.body = jsonEncode(data);
      }
      
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return null;
      } else {
        String errMsg = response.body;
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['message'] != null) errMsg = errJson['message'];
        } catch (_) {}
        throw Exception(errMsg);
      }
    } catch (e) {
      throw Exception("Bağlantı Kurulamadı: $e");
    }
  }

  static Future<String?> uploadFile(String endpoint, {Uint8List? bytes, String? filePath, required String filename}) async {
    try {
      final targetUrl = _buildUrl(endpoint);
      final headers = await _getHeaders();
      
      var request = http.MultipartRequest('POST', Uri.parse(targetUrl));
      request.headers.addAll(headers);
      
      // Web platformları path kullanmaz, byte array üzerinden yükler
      if (kIsWeb && bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      } else {
        throw Exception("Dosya bilgisi bulunamadı.");
      }
      
      var streamedResponse = await _client.send(request);
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var data = jsonDecode(response.body);
        return data['url'] as String?;
      } else {
        throw Exception("Dosya Yükleme Hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı Kurulamadı: $e");
    }
  }
}
