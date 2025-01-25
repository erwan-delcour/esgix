import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class ApiService {
  final http.Client client;

  ApiService(this.client);

  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    String? token,
  }) async {
    final headers = {
      'x-api-key': ApiConstants.apiKey,
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print("=== GET Request ===");
    print("URL: ${ApiConstants.baseUrl}$endpoint");
    print("Headers: $headers");

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          // Si la réponse est une liste, renvoyez une map vide avec une clé spéciale
          return {'data': decoded};
        } else if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception("Réponse inattendue : ${decoded.runtimeType}");
        }
      } catch (e) {
        print("Erreur lors du décodage JSON : $e");
        throw Exception("Réponse invalide : ${response.body}");
      }
    } else {
      throw Exception(
        'Erreur lors de la requête GET : ${response.statusCode} - ${response.body}',
      );
    }
  }

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
    }

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    print("=== POST Request ===");
    print("URL: ${ApiConstants.baseUrl}$endpoint");
    print("Headers: $headers");
    print("Body: ${jsonEncode(data)}");
    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body;
      } else {
        print("Type de réponse inattendu : ${body.runtimeType}");
        throw Exception(
          "Réponse inattendue pour la requête POST. Attendu : Map<String, dynamic>. Reçu : ${body.runtimeType}",
        );
      }
    } else {
      throw Exception(
        'Erreur lors de la requête POST : ${response.statusCode} - ${response.body}',
      );
    }
  }
}