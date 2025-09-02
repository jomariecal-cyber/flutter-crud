// personal_info_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_personal_info_screen.dart';  // <-- NEW: import the new screen

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  // Fetch data from API
  Future<List<Map<String, dynamic>>> fetchPersonalInfo() async {
    final response =
    await http.get(Uri.parse("http://10.21.1.128:8000/personalinfo"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded.containsKey("personalinfo")) {
        final list = decoded["personalinfo"];
        return List<Map<String, dynamic>>.from(list);
      } else {
        throw Exception("Unexpected JSON format");
      }
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Info"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPersonalInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            if (data.isEmpty) {
              return const Center(child: Text("No data available"));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.deepPurple.shade100,
                  ),
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columns: const [
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("First Name")),
                    DataColumn(label: Text("Last Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Created At")),
                  ],
                  rows: data.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row["customer_id"].toString())),
                      DataCell(Text(row["first_name"] ?? "")),
                      DataCell(Text(row["last_name"] ?? "")),
                      DataCell(Text(row["email"] ?? "")),
                      DataCell(Text(row["created_at"] ?? "")),
                    ]);
                  }).toList(),
                ),
              ),
            );
          } else {
            return const Center(child: Text("No data found"));
          }
        },
      ),

      // ✅ NEW Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddPersonalInfoScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
