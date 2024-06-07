import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miledrivers/components/MyTextInput.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final TextEditingController _inputController = TextEditingController();
  final storage = const FlutterSecureStorage();
  String phone = '';
  String email = '';
  String username = '';
  String userid = '';
  String error = '';
  var isLoading;
  bool successful = false;
  String _selectedOption = 'Friend\'s Phone';

  @override
  void initState() {
    super.initState();
    getToken();
  }

  getToken() async {
    var token = await storage.read(key: "milesjwt");
    var decoded = parseJwt(token.toString());
    if (decoded["error"] == "Invalid token") {
    } else {
      setState(() {
        userid = decoded["UserID"];
        username = decoded["Name"];
      });
    }
  }

  Future<void> _callNumber() async {
    String phoneNumber = phone.replaceFirst(RegExp(r'^0'), '+254');
    final String telLaunchUri = 'tel:$phoneNumber';
    if (await canLaunch(telLaunchUri)) {
      await launch(telLaunchUri);
    } else {
      setState(() {
        error = 'Could not launch $telLaunchUri';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Help",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            )
          ],
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Shadow color
                  spreadRadius: 5, // Spread radius
                  blurRadius: 7, // Blur radius
                  offset: const Offset(0, 3), // Offset from the top-left corner
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Call For Help:",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                DropdownButton<String>(
                  value: _selectedOption,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    }
                  },
                  dropdownColor:
                      Colors.amber, // Set the dropdown menu color to yellow
                  items: <String>['Friend\'s Phone', 'Emergency Call']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  iconEnabledColor:
                      Colors.black, // Change the icon color if needed
                  style: const TextStyle(
                      color: Colors.black), // Change the text color if needed
                ),
                const SizedBox(height: 20.0),
                MyTextInput(
                  title: _selectedOption == 'Friend\'s Phone'
                      ? 'Enter Friend\'s Phone Number'
                      : 'Enter Help Number',
                  lines: 1,
                  value: _selectedOption == 'Friend\'s Phone' ? '' : '999',
                  type: TextInputType.phone,
                  onSubmit: (value) {
                    setState(() {
                      phone = value ?? ''; // Ensure non-null value
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _callNumber,
                  child: const Text(
                    'Call For Help',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
