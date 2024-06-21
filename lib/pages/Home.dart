// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';

import 'package:miledrivers/components/ActiveItem.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:miledrivers/pages/complete.dart';
import 'package:miledrivers/pages/pending.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = const FlutterSecureStorage();
  List<dynamic> data = [];
  var isLoading;
  String enroute = 'false';
  String driverid = '';
  String name = '';
  String completed = "0";
  String total = "0";
  String pending = "0";
  String clientname = '';
  String clientphone = '';
  String reporttype = '';
  String incomingcalls = "";
  Timer? _timer;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    getUserInfo();
    fetchStats();
    fetchCurrent();
  }

  Future<void> getUserInfo() async {
    try {
      var token = await storage.read(key: "mdjwt");
      var decoded = parseJwt(token.toString());

      setState(() {
        name = decoded["Name"];
        driverid = decoded['DriverID'];
      });

      storage.write(key: "driverid", value: driverid);
    } catch (e) {}
  }

  Future<void> fetchStats() async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white, size: 100);
      });
      final response = await get(
        Uri.parse("${getUrl()}trips/status/Incoming"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 203) {
        var d = json.decode(response.body);

        print("incoming calls data: ${d["incoming"]}");

        setState(() {
          incomingcalls = d["incoming"].toString();
          total = d["incoming"].toString();
          pending = d["incoming"].toString();
          completed = d["incoming"].toString();
          isLoading = null;
        });

        print("incoming calls: $incomingcalls");
      } else {
        print("home response: ${response.body}");
        setState(() {
          isLoading = null;
        });
      }
    } catch (e) {
      print("home error: $e");
      setState(() {
        isLoading = null;
      });
    }
  }

  Future<void> fetchCurrent() async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.amber, size: 100);
      });
      final response = await get(
        Uri.parse("${getUrl()}trips/status/Picked"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 203) {
        var d = json.decode(response.body);

        print("incoming calls data: ${d["incoming"]}");

        setState(() {
          data = d["data"];
          isLoading = null;
        });

        print("incoming calls: $incomingcalls");
      } else {
        setState(() {
          isLoading = null;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = null;
      });
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Home: $name",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            SizedBox()
          ],
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            decoration: const BoxDecoration(color: Colors.white),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: RefreshIndicator(
                onRefresh: fetchStats,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Pending(driverid: driverid)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 32, 31, 31)
                                    .withOpacity(0.3), // Shadow color
                                spreadRadius: 2, // Spread radius
                                blurRadius: 5, // Blur radius
                                offset: const Offset(
                                    0, 3), // Changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    incomingcalls,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.call,
                                      size: 70,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      "Incoming Calls",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 24,
                                      ),
                                    )
                                  ],
                                ),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 32,
                                    color: Colors.black87,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 240, 238, 238),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 32, 31, 31)
                                  .withOpacity(0.3), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: const Offset(
                                  0, 3), // Changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.list,
                                    size: 32,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    child: Text(
                                      "Total Calls",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    total,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.black26,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.pending,
                                    size: 32,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    child: Text("Active Calls",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 20,
                                        )),
                                  ),
                                  Text(
                                    pending,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.black26,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.done,
                                    size: 32,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    child: Text("Completed Calls",
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 20)),
                                  ),
                                  Text(
                                    completed,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Pending(
                                    driverid: driverid,
                                  ),
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 240, 238, 238),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 32, 31, 31)
                                              .withOpacity(0.3), // Shadow color
                                      spreadRadius: 2, // Spread radius
                                      blurRadius: 5, // Blur radius
                                      offset: const Offset(
                                          0, 3), // Changes position of shadow
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "New Calls",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 32,
                                      color: Colors.black87,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      Complete(driverid: driverid),
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 240, 238, 238),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 32, 31, 31)
                                              .withOpacity(0.3), // Shadow color
                                      spreadRadius: 2, // Spread radius
                                      blurRadius: 5, // Blur radius
                                      offset: const Offset(
                                          0, 3), // Changes position of shadow
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Completed Calls",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 32,
                                      color: Colors.black87,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Active Calls",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      if (data.isNotEmpty)
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ActiveItem(
                                  item: data[index], index: index);
                            })
                      else
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "You do not have any active calls. Go to 'New Calls' to select a call",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 20, color: Colors.black87),
                          ),
                        ),
                      const SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Center(
              child: isLoading,
            ),
          )
        ],
      ),
    );
  }
}

class Message {
  var token;
  var success;
  var error;

  Message({
    required this.token,
    required this.success,
    required this.error,
  });

  factory Message.fromJson(json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
    );
  }
}
