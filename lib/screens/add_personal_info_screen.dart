import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPersonalInfoScreen extends StatefulWidget {
  const AddPersonalInfoScreen({super.key});

  @override
  State<AddPersonalInfoScreen> createState() => _AddPersonalInfoScreenState();
}

class _AddPersonalInfoScreenState extends State<AddPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for inputs
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Save data to backend
  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse("http://10.21.1.128:8000/personalinfo"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "first_name": _firstNameController.text,
            "last_name": _lastNameController.text,
            "email": _emailController.text,
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Decode success response
          final responseData = jsonDecode(response.body);
          final message = responseData["message"] ?? "Saved successfully";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          Navigator.pop(context, true); // Go back
        } else {
          // Decode error response from backend
          final responseData = jsonDecode(response.body);
          final errorMessage = responseData["detail"] ??
              "Failed to save data. Code: ${response.statusCode}";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        // Handle unexpected errors (like server down or JSON decode fail)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Personal Info"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // First Name field
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter first name" : null,
              ),
              // Last Name field
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter last name" : null,
              ),
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 20),
              // Save button
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
