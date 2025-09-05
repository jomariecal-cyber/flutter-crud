import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:i_am_rich/loanapp/loan_details.dart';

class loan extends StatefulWidget {
  const loan({super.key});

  @override
  State<loan> createState() => _loanState();
}

class _loanState extends State<loan> {
  String? selectedInstiName;
  int? selectedInstiValue;
  String? selectedTerm;

  //loan Details

  final List<Map<String, dynamic>> institutions = [
    {"name": "CARD RBI", "value": 100},
    {"name": "CARD INC.", "value": 200},
  ];

  final List<String> terms = [];
  List<String> loanTerms = [];
  bool isLoadingTerms = true;

  final TextEditingController balanceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();


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
          print('ecaljomari');
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

// loan details declaration
  Map<String, dynamic>? loanDetails;


  Future<Map<String, dynamic>> fetchLoanDetails() async {
    final url = Uri.parse("https://dev-api-janus.fortress-asya.com:18003/loanCalculator");

    // Sample request body (later you can replace with actual values from your form)
    final body = {
      "instiCode": "100",
      "loanBalance": 9000,
      "principal": "3000",
      "n": 4,
      "meetingDay": 3,
      "loanProductCode": 302,
      "withDST": 0,
      "isLumpsum": 0,
      "frequency": 50,
      "dateReleased": "2025-09-04 09:25:59.496478"
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<String,dynamic> detailsFromApi = data["data"];
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch loan details: ${response.statusCode}");
    }
  }




  // need to init state to check if the fetchloanterms setstate is calling
  @override
  void initState() {
    fetchLoanTerms();
    fetchLoanDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Personal Info"),
      ),
      body: Container(
         color: Colors.grey.shade50,
        child: Padding(
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
                    labelText: "Choose Institution",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                        selectedInstiName= newValue;
                        selectedInstiValue = institutions
                            .firstWhere((insti) => insti["name"] == newValue) ["value"];
                      });
                    print("Selected: $selectedInstiName, Value: $selectedInstiValue");
                  },
                  items: institutions.map((insti) {
                      return DropdownMenuItem<String>(
                        value: insti["name"],
                        child: Text(insti["name"]),
                      );
                    }).toList(),
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

              SizedBox(height: 50),

              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       print("Button pressed!");
              //     },
              //     child: const Text("Submit"),
              //   ),
              // ),


//loan Details
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final details = await fetchLoanDetails();
                      setState(() {
                        loanDetails = details;
                      });

                      // Show loan details in a bottom sheet (half screen)
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            height: MediaQuery.of(context).size.height * 0.5, // Half screen
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Loan Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Text(loanDetails.toString()), // Replace with styled fields
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),

              )


            ],



          ),
        ),
      ),
    );
  }
}
