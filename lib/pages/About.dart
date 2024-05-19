import 'package:miledrivers/components/MyDrawer.dart';
import 'package:miledrivers/components/TextLarge.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<StatefulWidget> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "About",
        home: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    "About",
                    style: TextStyle(color: Colors.white),
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
            backgroundColor: Color.fromRGBO(0, 96, 177, 1),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: const Drawer(child: MyDrawer()),
          body: Container(
              child: const Column(children: <Widget>[
            TextLarge(label: "Introduction"),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text(
                  "Ambulex Solutions is a Kenyan start-up that seeks to have a significant socio-economic impact in Kenya by contributing to the healthcare system to give residents of low-income areas access to affordable and timely emergency medical care, saving lives and giving people a second chance at life and a chance to be active participants in their communities."),
            ),
            TextLarge(label: "Scope"),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text(
                  "Ambulex through this mobile application offers emergency response services for the following incidences"),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text("GENDER BASED VIOLENCE"),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text(
                "MEDICAL EMERGENCIES",
                textAlign: TextAlign.left,
              ),
            ),
          ])),
        ));
  }
}
