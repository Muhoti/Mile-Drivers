import 'package:flutter/material.dart';
import 'package:mile_driver/components/mydrawer.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const MyDrawer(),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Our app is committed to ensuring the privacy and security of your personal data. This Privacy Policy explains how we collect, use, and protect your information when you use our app.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '1. Personal Details: We may collect personal details such as your name, phone number, ID number, and email address for account registration and authentication purposes.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              '2. Location Information: Our app may collect and store your location information to provide location-based services, such as mapping features. You can control the app’s access to your location through your device settings.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              '3. Camera Usage: We may request access to your device’s camera for features such as capturing images or scanning QR codes. We do not store images captured by the camera unless explicitly permitted by you.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              '4. Access to System Files and Documents: Our app may require access to system files and documents on your device to perform specific functions, such as importing or exporting data. We ensure that this access is limited to what is necessary for the app’s functionality and does not compromise your data security.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Data Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We implement appropriate technical and organizational measures to safeguard your personal data against unauthorized access, alteration, disclosure, or destruction. Your data is stored securely and accessed only by authorized personnel.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Changes to This Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We reserve the right to update or modify this Privacy Policy at any time. Any changes will be effective immediately upon posting the updated Privacy Policy on this page. We encourage you to review this Privacy Policy periodically for any updates.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'If you have any questions or concerns about our Privacy Policy or the handling of your personal data, please contact us at [contact email/phone number].',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
