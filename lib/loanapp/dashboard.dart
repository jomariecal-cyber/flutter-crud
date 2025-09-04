import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class loan extends StatefulWidget {
  const loan({super.key});

  @override
  State<loan> createState() => _loanState();
}

class _loanState extends State<loan> {
  String? selectedInsti;
  String? selectedTerm;
  final List<String> items = ["CARD RBI", "CARD INC."];
  final List<String> terms = [];
  List<String> loanTerms = [];
  bool isLoadingTerms = true;




  Future<void> fetchLoanTerms() async {
    final url = Uri.parse("https://dev-api-janus.fortress-asya.com:18003/getLoanTermV2");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "frequency": "Weekly",
          "amount": 0,
          "product_code": 301
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Assuming response looks like { "terms": [6, 12, 18, 24] }
        List<dynamic> termsFromApi = data["data"];
        print(termsFromApi);

        setState(() {
          //print('object');
          //loanTerms = termsFromApi.map((term) => term.toString()).toList();
          loanTerms = termsFromApi.map((term) => term["title"].toString()).toList();
          isLoadingTerms = false;
        });
      } else {
        throw Exception("Failed to load loan terms: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching loan terms: $e");
      setState(() {
        isLoadingTerms = false;
      });
    }
  }

  @override
  void initState() {
    fetchLoanTerms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Personal Info"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please select an Institution"),
            const SizedBox(
              height: 10,
            ),



            Center(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Choose Option",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedInsti,
                onChanged: (newValue) {
                  setState(
                    () {
                      selectedInsti = newValue;
                    },
                  );
                },
                items: items.map(
                  (item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  },
                ).toList(),
              ),

            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.number,
              //controller: textController,
              decoration: InputDecoration(
                labelText: "Enter your loan Balance",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.number,
              //controller: textController,
              decoration: InputDecoration(
                labelText: "Enter your loan Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            isLoadingTerms
            ? const CircularProgressIndicator()
            : DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Choose Loan Term",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedTerm,
              onChanged: (newValue) {
                setState(
                      () {

                        isLoadingTerms = false;
                    selectedTerm = newValue;
                  },
                );
              },
              items: loanTerms.map(
                    (item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, ),

                  );
                },
              ).toList(),
            ),
          ],



        ),
      ),
    );
  }
}
