// services/delete_personal_info_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeletePersonalInfoService {
  static Future<Map<String, dynamic>> deletePersonalInfo(int customerId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.21.1.128.0.0.1:8000/personalinfo/$customerId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": data["message"] ?? "Deleted successfully"
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["detail"] ??
              "Failed to delete. Code: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}
