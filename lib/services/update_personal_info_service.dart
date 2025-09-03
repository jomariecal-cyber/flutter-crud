// services/update_personal_info_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdatePersonalInfoService {
  static const String baseUrl = "http://10.21.1.128:8000";

  /// Updates personal info at /personalinfo/{customer_id}
  static Future<String> updatePersonalInfo({
    required int customerId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/personalinfo/$customerId');

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
        }),
      );

      print("PUT $url");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded["message"] ?? "Update successful";
      } else {
        // Handle error responses with `detail`
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey("detail")) {
            return decoded["detail"]; // e.g. "Duplicate email found"
          }
        } catch (_) {
          // ignore JSON errors
        }

        // Fallback messages
        if (response.statusCode == 400) {
          return "Invalid input or duplicate data";
        } else if (response.statusCode == 404) {
          return "Customer not found";
        } else if (response.statusCode == 500) {
          return "Update failed, please try again";
        } else {
          return "Unexpected error: ${response.statusCode}";
        }
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
