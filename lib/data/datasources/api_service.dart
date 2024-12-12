import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class ApiService {
  final http.Client client;

  ApiService(this.client);

  /// Requête GET (avec ou sans Auth)
  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    String? token,  // Le token est optionnel
  }) async {
    final headers = {
      'x-api-key': ApiConstants.apiKey,
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Erreur lors de la requête GET : ${response.statusCode}');
    }
  }

  /// Requête POST avec Logs
  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final headers = {
      'x-api-key': ApiConstants.apiKey,
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("Erreur: Token non fourni !");
    }

    print("Headers: $headers");

    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    print("=== POST Request ===");
    print("URL: $url");
    print("Headers: $headers");
    print("Body: ${jsonEncode(data)}");

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Erreur lors de la requête POST : ${response.statusCode}');
    }
  }
}