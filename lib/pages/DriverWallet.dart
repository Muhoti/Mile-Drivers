// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mile_driver/components/MyTextInput.dart';
import 'package:mile_driver/components/Utils.dart';
import 'package:mile_driver/pages/Login.dart';

import '../components/TextOakar.dart';

class DriverWallet extends StatefulWidget {
  final double balance;

  const DriverWallet({
    super.key,
    required this.balance,
  });

  @override
  State<DriverWallet> createState() => _DriverWalletState();
}

class _DriverWalletState extends State<DriverWallet> {
  String phone = '';
  String amount = '';
  String driverid = '';
  double accountbalance = 0.0;
  String error = '';

  bool successful = false;
  var isLoading;
  bool _isLoading = false;

  List<Transaction> transactions = [];
  final storage = const FlutterSecureStorage();

  Timer? _pollingTimer;

  Future<void> pollForPaymentStatus(String checkoutRequestID) async {
    print("request id: $checkoutRequestID");
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final response = await get(
          Uri.parse("${getUrl()}payment-status/$checkoutRequestID"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);

          print("payment status wallet: $result");

          if (result['success']) {
            setState(() {
              error = "Payment successful";
              successful = true;
              _isLoading = false;
            });

            timer.cancel();
            await saveTransactionToDatabase(result, driverid);
            await updateTransactionsList(driverid);
          } else {
            setState(() {
              error = result['message'];
              successful = false;
              _isLoading = false;
            });
            timer.cancel(); // Stop polling after failure
          }
        }
      } catch (e) {
        print("Error polling payment status: $e");
        setState(() {
          _isLoading = false;
          error = "Failed to fetch payment status!";
        });
        timer.cancel();
      }
    });
  }

  Future<Message> withdrawFunds(String phone, String amount) async {
    if (phone.isEmpty) {
      return Message(error: "Phone number is empty!");
    }
    if (double.tryParse(amount) == null || double.parse(amount) <= 0) {
      return Message(error: "Invalid amount entered!");
    }

    try {
      final response = await post(
        Uri.parse("${getUrl()}withdraw"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "phone_number": phone,
          "amount": double.tryParse(amount) ?? 0,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        var a = jsonDecode(response.body);
        String checkoutRequestID = a['data']['CheckoutRequestID'];
        print("STK Push initiated: $checkoutRequestID");

        // Start polling for the payment result
        pollForPaymentStatus(checkoutRequestID);

        return Message.fromJson(jsonDecode(response.body));
      } else {
        // Handle error responses
        try {
          return Message(
              error: jsonDecode(response.body)['error'] ?? "Server Error!");
        } catch (e) {
          return Message(error: "Unexpected server response: ${response.body}");
        }
      }
    } catch (e) {
      print("wallet error: $e");
      return Message(error: "Connection to server failed! Error: $e");
    }
  }

  Future<void> handleWithdraw() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      error = "Awaiting Withdraw...";
    });

    final response = await withdrawFunds(phone, amount);

    setState(() {
      _isLoading = false;
      if (response.error == null) {
        error = "STK Push Initiated. Awaiting payment confirmation";
        successful = true;
      } else {
        error = response.error!;
        successful = false;
      }
    });
  }

  Future<void> updateTransactionsList(driverid) async {
    print("transacationslist id: $driverid");

    setState(() {
      isLoading = LoadingAnimationWidget.staggeredDotsWave(
        color: const Color.fromARGB(255, 23, 117, 126),
        size: 100,
      );
    });

    try {
      final response = await get(
        Uri.parse("${getUrl()}transaction/driverid/$driverid"),
      );

      if (response.statusCode == 200) {
        // Parsing the response body only if it's successful (status 200)
        var data = json.decode(response.body);
        print("transactions here: $data");

        setState(() {
          error = "";
          transactions.clear();
          accountbalance = 0.0;

          // Assuming the data is a list of transactions
          for (var item in data) {
            final transaction = Transaction(
              type: item['Type']?.toString() ?? 'N/A',
              amount: item['Amount']?.toString() ?? '0.00',
              date: item['Date']?.toString() ?? DateTime.now().toString(),
              receipt: item['Receipt']?.toString() ?? 'N/A',
              phoneNumber: item['Phone']?.toString() ?? 'N/A',
              message: 'Transaction loaded successfully',
            );

            // Add each transaction to the list of transactions
            transactions.add(transaction);

            transaction.type == 'ride_payment'
                ? accountbalance += double.tryParse(transaction.amount) ?? 0.0
                : accountbalance = accountbalance;
          }
          isLoading = null;
        });
      } else {
        // Log the response for non-200 status codes
        print("Error: ${response.statusCode}, Body: ${response.body}");
        setState(() {
          error = "Failed to load transactions";
          isLoading = null;
        });
      }
    } catch (e) {
      print("transactions error: $e");
      setState(() {
        error = "An error occurred while fetching transactions";
        isLoading = null;
      });
    }
  }

  getToken() async {
    var token = await storage.read(key: "mdjwt");
    var decoded = parseJwt(token.toString());
    var _phone = decoded["Phone"];

    _phone.startsWith('0')
        ? _phone = '254${_phone.substring(1)}'
        : _phone = _phone;

    if (decoded["error"] == "Invalid token") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Login()));
    } else {
      setState(() {
        driverid = decoded["DriverID"];
        phone = _phone;
      });
      updateTransactionsList(driverid);
    }
  }

  @override
  void initState() {
    getToken();

    super.initState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Wallet'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.amber[300],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'KES ${accountbalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyTextInput(
                      title: 'Enter Phone Number',
                      lines: 1,
                      value: phone,
                      type: TextInputType.phone,
                      onSubmit: (value) => setState(() => phone = value),
                    ),
                    const SizedBox(height: 10),
                    MyTextInput(
                      title: 'Enter Amount to Upload',
                      lines: 1,
                      value: amount,
                      type: TextInputType.number,
                      onSubmit: (value) => setState(() => amount = value),
                    ),
                    TextOakar(label: error, issuccessful: successful),
                    _isLoading == false
                        ? ElevatedButton.icon(
                            onPressed: handleWithdraw,
                            icon: const Icon(Icons.arrow_circle_down,
                                color: Colors.amber),
                            label: const Text(
                              'Withdraw',
                              style: TextStyle(color: Colors.amber),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          )
                        : LoadingAnimationWidget.horizontalRotatingDots(
                            color: const Color.fromARGB(248, 186, 12, 47),
                            size: 100,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            isLoading == null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        print("transactions list: ${transactions[index]}");
                        return ListTile(
                          leading: Icon(
                            transaction.type == 'ride_payment'
                                ? Icons.local_taxi
                                : Icons.credit_card,
                            color: transaction.type == 'ride_payment'
                                ? Colors.red
                                : Colors.green,
                          ),
                          title: Text(
                            transaction.type == 'ride_payment'
                                ? 'Ride Payment'
                                : 'Top Up Wallet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.type == 'ride_payment'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          subtitle: Text(transaction.date,
                              style: const TextStyle(color: Colors.black54)),
                          trailing: Text(
                            'KES ${transaction.amount}',
                            style: TextStyle(
                              color: transaction.type == 'ride_payment'
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(child: isLoading),
          ],
        ),
      ),
    );
  }
}

Future<Message> saveTransactionToDatabase(result, driverid) async {
  print("saved result: ${result["phoneNumber"]}");

  try {
    final response = await post(
      Uri.parse("${getUrl()}transaction/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "DriverID": driverid,
        "Phone": result["phoneNumber"].toString(),
        "Amount": result["amount"].toString(),
        "Receipt": result["receipt"].toString(),
        "Date": DateTime.now().toString(),
        "Type": "top_up"
      }),
    );

    print("body is ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 203) {
      print("response status: ${response.statusCode}");
      return Message.fromJson(jsonDecode(response.body));
    } else {
      return Message(
        token: null,
        success: null,
        error: "Server Error! Connection Failed!",
      );
    }
  } catch (e) {
    print("error transactions: $e");
    return Message(
      token: null,
      success: null,
      error: "Connection to server failed!",
    );
  }
}

class Transaction {
  final String type;
  final String amount;
  final String date;
  final String receipt;
  final String phoneNumber;
  final String message;

  Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.receipt,
    required this.phoneNumber,
    required this.message,
  });
}

class Message {
  var token;
  var success;
  var error;

  Message({
    this.token,
    this.success,
    required this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
    );
  }
}
