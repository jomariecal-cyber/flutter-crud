// screens/personal_info_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_personal_info_screen.dart'; // For adding info
import 'update_personal_info_screen.dart'; // For updating info

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  // Fetch personal info from API
  Future<List<Map<String, dynamic>>> fetchPersonalInfo() async {
    final response =
    await http.get(Uri.parse("http://10.21.1.128:8000/personalinfo"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Make sure the response has "personalinfo" key
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
        centerTitle: true,
        title: const Text("Personal Info"),
        backgroundColor: Colors.deepPurple,
      ),


      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ],
        ),
      ),



      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPersonalInfo(),
        builder: (context, snapshot) {
          // Show loading spinner while waiting for API
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error if something went wrong
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // Show table if data is available
          else if (snapshot.hasData) {
            final data = snapshot.data!;

            if (data.isEmpty) {
              return const Center(child: Text("No data available"));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final row = data[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.deepPurple),
                    title: Text(
                      "${row["first_name"] ?? ""} ${row["last_name"] ?? ""}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(row["email"] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdatePersonalInfoScreen(
                              customerId: row["customer_id"],
                              firstName: row["first_name"] ?? "",
                              lastName: row["last_name"] ?? "",
                              email: row["email"] ?? "",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );


            // Scrollable DataTable
            // return SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.vertical,
            //     child: DataTable(
            //       headingRowColor: MaterialStateColor.resolveWith(
            //             (states) => Colors.deepPurple.shade100,
            //       ),
            //       border: TableBorder.all(color: Colors.grey.shade300),
            //       columns: const [
            //         //DataColumn(label: Text("ID")),
            //         DataColumn(label: Text("First Name")),
            //         DataColumn(label: Text("Last Name")),
            //         DataColumn(label: Text("Email")),
            //       //  DataColumn(label: Text("Created At")),
            //         DataColumn(label: Text("Actions")), // ✅ New column for Edit
            //       ],
            //       rows: data.map((row) {
            //         return DataRow(cells: [
            //           //DataCell(Text(row["customer_id"].toString())),
            //           DataCell(Text(row["first_name"] ?? "")),
            //           DataCell(Text(row["last_name"] ?? "")),
            //           DataCell(Text(row["email"] ?? "")),
            //          // DataCell(Text(row["created_at"] ?? "")),
            //           // ✅ Edit button
            //           DataCell(
            //             IconButton(
            //               icon: const Icon(Icons.edit, color: Colors.deepPurple),
            //               onPressed: () {
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) => UpdatePersonalInfoScreen(
            //                       customerId: row["customer_id"],
            //                       firstName: row["first_name"] ?? "",
            //                       lastName: row["last_name"] ?? "",
            //                       email: row["email"] ?? "",
            //                     ),
            //                   ),
            //                 );
            //               },
            //             ),
            //           ),
            //         ]);
            //       }).toList(),
            //     ),
            //   ),
            // );

          } else {
            return const Center(child: Text("No data found"));
          }
        },
      ),

      // ✅ Floating button for adding new record
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
