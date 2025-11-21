import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthApi {

  // Use env var if provided, otherwise fallback to local dev URL.
  // dotenv.env returns String?, so use ?? to provide a non-null String.
  String baseUrl = dotenv.env['API_URL'] ?? "http://10.0.2.2:8081/api";

  late final authApiUrl = Uri.parse("$baseUrl/auth");

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$authApiUrl/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error ${response.statusCode}: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String gender, String username, String password, String birthday) async {
    final url = Uri.parse("$authApiUrl/register/patient");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "gender": gender, //MALE || FEMALE
        "username": username,
        "password": password,
        "birthday": birthday
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error ${response.statusCode}: ${response.body}");
    }
  }
}
