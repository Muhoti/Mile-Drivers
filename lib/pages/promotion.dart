import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miledrivers/components/MyTextInput.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:url_launcher/url_launcher.dart';

class Promotion extends StatefulWidget {
  @override
  _PromotionState createState() => _PromotionState();
}

class _PromotionState extends State<Promotion> {
  final TextEditingController _inputController = TextEditingController();
  final storage = const FlutterSecureStorage();
  String phone = '';
  String email = '';
  String username = '';
  String userid = '';
  String error = '';
  var isLoading;
  bool successful = false;
  String _selectedOption = 'Phone';

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

  Future<void> _sendInvite() async {
    String inviteLink = generateUniqueLink(userid, username);
    String recipient = _selectedOption == 'Phone' ? phone : email;

    if (recipient == phone) {
      final String smsLaunchUri = '${Uri(
        scheme: 'sms',
        path: phone.replaceFirst(RegExp(r'^.'), '+254'),
      )}?body=${Uri.encodeComponent('Hey pal, click here for the best cab service ever! $inviteLink?').replaceAll('+', ' ')}';
      await launchUrl(Uri.parse(smsLaunchUri));
    } else {
      final String emailLaunchUri = '${Uri(
        scheme: 'mailto',
        path: email,
      )}?subject=${Uri.encodeComponent('Join the Best Cab Service!').replaceAll('+', ' ')}&body=${Uri.encodeComponent('Hey pal, click here for the best cab service ever! $inviteLink?').replaceAll('+', ' ')}';
      await launchUrl(Uri.parse(emailLaunchUri));
    }
  }

  String generateUniqueLink(String userId, String userName) {
    String referralCode = generateReferralCode(userId, userName);
    print("referral code: $referralCode");
    return 'https://strongmuhoti.co.ke/install?referralCode=$referralCode';
  }

  String generateReferralCode(String userId, String userName) {
    String randomString = DateTime.now().millisecondsSinceEpoch.toString();
    return '$userId$userName$randomString';
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
                "Promotion",
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
                  "Invite Friend Via:",
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
                  items: <String>['Phone', 'Email'].map((String value) {
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
                _selectedOption == 'Phone'
                    ? MyTextInput(
                        title: 'Enter friend\'s Phone Number',
                        lines: 1,
                        value: '',
                        type: TextInputType.phone,
                        onSubmit: (value) {
                          // Nullable string
                          setState(() {
                            phone = value ?? ''; // Ensure non-null value
                          });
                        },
                      )
                    : MyTextInput(
                        title: 'Enter friend\'s Email',
                        lines: 1,
                        value: '',
                        type: TextInputType.emailAddress,
                        onSubmit: (value) {
                          // Nullable string
                          setState(() {
                            email = value ?? ''; // Ensure non-null value
                          });
                        },
                      ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _sendInvite,
                  child: const Text(
                    'Send Invite',
                    style: TextStyle(color: Colors.black87),
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
