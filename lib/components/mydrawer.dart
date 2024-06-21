import 'package:miledrivers/components/FootNote.dart';
import 'package:miledrivers/pages/About.dart';
import 'package:miledrivers/pages/Login.dart';
import 'package:miledrivers/pages/Partnerships.dart';
import 'package:miledrivers/pages/Settings.dart';
import 'package:miledrivers/pages/help.dart';
import 'package:miledrivers/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miledrivers/pages/privaypolicy.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  TextStyle style = const TextStyle(
      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: Colors.amber),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                  )),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const Home()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.home_outlined,
                                size: 30, color: Colors.black87),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Home',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicy()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_moon_outlined,
                                size: 30, color: Colors.black87),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const About()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                size: 30, color: Colors.black87),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'About',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => Partneships()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.bookmark_add_outlined,
                              size: 30,
                              color: Colors.black87,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Partnerships',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => Help()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.local_hospital,
                              size: 30,
                              color: Colors.black87,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Help',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GestureDetector(
                        onTap: () {
                          const store = FlutterSecureStorage();
                          store.deleteAll();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const Login()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.logout, size: 30, color: Colors.black87),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Settings()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.settings,
                                size: 30, color: Colors.black87),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'My Settings',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const Align(alignment: Alignment.bottomLeft, child: FootNote())
          ],
        ),
      ),
    );
  }
}
