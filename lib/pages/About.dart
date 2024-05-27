import 'package:flutter/material.dart';
import 'package:miledrivers/components/mydrawer.dart';

class About extends StatelessWidget {
  const About({super.key});

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
          'About',
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
              'Welcome to Mile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Mile is not just another cab booking app; it’s your personalized chauffeur service designed to make every journey memorable. With Mile, your comfort, safety, and convenience are our top priorities.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Our Commitment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'At Mile, we are committed to providing you with the ultimate transportation experience. Whether you’re heading to a business meeting, catching a flight, or simply exploring the city, we strive to exceed your expectations at every turn.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Seamless Booking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Gone are the days of waiting on street corners or frantically waving down passing cabs. With Mile, booking your ride is as easy as tapping a button. Simply enter your destination, choose your vehicle, and let us handle the rest. It’s transportation made simple.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Safety First',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your safety is our priority. All Mile drivers undergo rigorous background checks and training to ensure your peace of mind. Plus, our state-of-the-art tracking system allows you to monitor your ride in real-time, so you can always feel secure.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Customized Experience',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We understand that every passenger is unique. That’s why Mile offers a range of vehicle options to suit your preferences and needs. Whether you’re traveling solo, with friends, or with family, we’ve got the perfect ride for you.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Affordable Rates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Enjoy luxury transportation without breaking the bank. With competitive rates and transparent pricing, Mile makes premium travel accessible to everyone. No hidden fees, no surprises – just exceptional service at an unbeatable value.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '24/7 Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Got a question or concern? Our dedicated support team is here to assist you around the clock. Whether you need help with a booking, have a special request, or simply want to provide feedback, we’re always just a message away.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Environmentally Friendly',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'At Mile, we’re committed to sustainability. By opting for our ride-sharing services, you’re not only saving time and money – you’re also reducing your carbon footprint. Join us in our mission to create a greener, cleaner future, one ride at a time.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Join the Mile Community',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ready to experience transportation reimagined? Download the Mile app today and join thousands of satisfied passengers who rely on us for their travel needs. Wherever you’re going, go with Mile – the journey starts here.',
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
