import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoanFormScreen extends StatefulWidget {
  @override
  _LoanFormScreenState createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  String? selectedInstitution;
  String? selectedLoanTerm;
  TextEditingController loanBalanceController = TextEditingController();
  TextEditingController loanAmountController = TextEditingController();

  bool isLoadingTerms = true;
  List<String> loanTerms = [];

  bool isLoadingDetails = false;
  List<String> loanDetails = [];

  bool isLoadingtermValues = true;
  Map<String, int> termValues = {};

  @override
  void initState() {
    super.initState();
    fetchLoanTerms(); // ✅ only fetch terms, don’t submit immediately
  }

  // Fetch loan terms from API ==========================================================
  Future<void> fetchLoanTerms() async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://dev-api-janus.fortress-asya.com:18003/getLoanTermV2"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "frequency": "Weekly",
          "amount": 0,
          "product_code": 301,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> termsFromApi = data["data"] ?? [];
        setState(() {
          loanTerms = termsFromApi
              .map((term) => term["title"].toString())
              .toList(); // store the values for dropdown

          // also store id/value mapping so you can fetch n easily
          termValues = {
            for (var term in termsFromApi) term["title"]: term["value"]
          };

          isLoadingTerms = false;
        });
      } else {
        setState(() => isLoadingTerms = false);
        print("❌ Failed to load loan terms: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoadingTerms = false);
      print("❌ Exception fetching terms: $e");
    }
  }

  // Submit and navigate ================================================================
  Future<void> submitLoanDetails() async {
    if (selectedInstitution == null ||
        selectedLoanTerm == null ||
        loanBalanceController.text.isEmpty ||
        loanAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final url = Uri.parse(
        "https://dev-api-janus.fortress-asya.com:18003/loanCalculator");

    final body = {
      "instiCode": selectedInstitution,
      "loanBalance": int.tryParse(loanBalanceController.text) ?? 0,
      "principal": int.tryParse(loanAmountController.text) ?? 0,
      // "n":  int.tryParse(selectedLoanTerm ?? "0") ?? 0,
      "n": termValues[selectedLoanTerm] ?? 0, // <-- only number from API
      "meetingDay": 3,
      "loanProductCode": 302,
      "withDST": 0,
      "isLumpsum": 0,
      "frequency": 50,
      "dateReleased": DateTime.now().toIso8601String(),
    };

    print("📤 Request Body: ${jsonEncode(body)}");

    try {
      setState(() => isLoadingDetails = true);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final loanData = jsonDecode(response.body);

        print("✅ Loan details fetched successfully: $loanData");

        final data = loanData["data"] as Map<String, dynamic>;
        showLoanDetailsModal(context, data);

        setState(() {
          loanDetails =
              data.entries.map((e) => "${e.key}: ${e.value}").toList();
          isLoadingDetails = false;
        });
      } else {
        setState(() => isLoadingDetails = false);
        print(
            "❌ Failed with status: ${response.statusCode}, body: ${response.body}");
        _showErrorDialog("Failed to submit loan details");
      }
    } catch (e) {
      setState(() => isLoadingDetails = false);
      print("❌ Exception: $e");
      _showErrorDialog("An error occurred: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Show loan details modal ============================================================
  void showLoanDetailsModal(BuildContext context, Map<String, dynamic> data) {
    final Map<String, String> labels = {
      'loanAmount': 'Loan Amount',
      'effectiveInterestRate': 'Effective Interest Rate',
      'contractualRate': 'Contractual Rate',
      'loanInterest': 'Loan Interest',
      'loanInterestRate': 'Loan Interest Rate',
      'loanOutstanding': 'Loan Outstanding',
      'numberOfMonths': 'Number of Months',
      'numberOfWeeks': 'Number of Weeks',
      'lrf': 'Loan Redemption Fund',
      'loanProceeds': 'Loan Proceeds',
      'amountInWords': 'Amount in Words',
      'weeklyDue': 'Weekly Due',
      'dateRelease': 'Date Released',
      'firstPayment': 'First Payment',
      'maturityDate': 'Maturity Date',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.3,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Loan Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Expanded(
                  // Fills the remaining space inside a Row/Column (a Flex parent).
                  child: ListView(
                    // A scrollable vertical list of widgets.
                    children: data
                        .entries // Take all key–value pairs from the Map `data` as Iterable<MapEntry>.
                        .where(
                          (e) => // Keep only entries that match a condition…
                              labels.keys.contains(e.key),
                        ) // …specifically: the entry's key exists in the `labels` map.
                        .map(
                          (e) => ListTile(
                            // Ready-made row layout: leading | title/subtitle | trailing.
                            title: Text(
                              // The primary text (label).
                              labels[e.key] ??
                                  e.key, // Use pretty label from `labels`; fallback to the raw key.
                              style: const TextStyle(
                                  // Styling for the title text.
                                  fontWeight: // Make it bold for emphasis.
                                      FontWeight.bold,
                                  fontSize:
                                      14), // Slightly larger than default.
                            ),
                            subtitle: Text(
                              // The secondary text (value).
                              "${e.value ?? 'N/A'}", // Show the value; if null, display 'N/A'.
                            ),
                          ),
                        )
                        .toList(), // Convert the Iterable<Widget> from .map into a List<Widget>.
                  ),
                ),

                // Expanded(
                //   child: ListView(
                //     controller: scrollController,
                //     children: data.entries
                //         .where((e) => [
                //       'loanAmount',
                //       'effectiveInterestRate',
                //       'contractualRate'
                //     ].contains(e.key)) // ✅ keep only these keys
                //         .map((e) => ListTile(
                //       title: Text("${e.key}: ${e.value ?? 'N/A'}"),
                //     ))
                //         .toList(),
                //   ),
                // ),

                // Expanded(
                //   child: ListView(
                //     controller: scrollController,
                //     children: data.entries
                //         .map((e) => ListTile(
                //               title: Text("${e.key}: ${e.value}"),
                //             ))
                //         .toList(),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Done",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // UI ================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loan Application")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Institution Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Institution",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "100", child: Text("CARD INC. Institution 1")),
                  DropdownMenuItem(value: "200", child: Text("CARD RBI Institution 2")),
                ],
                onChanged: (val) => setState(() => selectedInstitution = val),
              ),
              const SizedBox(height: 16),

              // Loan Balance
              TextField(
                controller: loanBalanceController,
                decoration: const InputDecoration(
                  labelText: "Enter Loan Balance",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Loan Amount
              TextField(
                controller: loanAmountController,
                decoration: const InputDecoration(
                  labelText: "Enter Loan Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Loan Term Dropdown
              isLoadingTerms
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Select Loan Term",
                        border: OutlineInputBorder(),
                      ),
                      items: loanTerms.map((title) {
                        return DropdownMenuItem(
                          value: title,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => selectedLoanTerm = val),
                    ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: isLoadingDetails ? null : submitLoanDetails,
                child: isLoadingDetails
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 8, 38, 206),
                        //padding EdgeInsets.all(5.0),
                      )
                    : const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
