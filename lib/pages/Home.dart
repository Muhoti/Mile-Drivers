import 'dart:async';
import 'dart:convert';

import 'package:miledrivers/components/ActiveItem.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:miledrivers/pages/Login.dart';
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
  String erid = '';
  String name = '';
  String completed = "0";
  String total = "0";
  String pending = "0";
  String clientname = '';
  String clientphone = '';
  String reporttype = '';
  String incomingcalls = "0";
  Timer? _timer;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    getUserInfo();
    checkIncomingCalls();
  }

  Future<void> getUserInfo() async {
    try {
      var token = await storage.read(key: "mdjwt");
      var decoded = parseJwt(token.toString());

      setState(() {
        name = decoded["Name"];
        erid = decoded['ERTeamID'];
      });
      storage.write(key: "erid", value: erid);
      countTasks();
        } catch (e) {}
  }

  Future<void> countTasks() async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.horizontalRotatingDots(
            color: Colors.orange, size: 64);
      });
      final response = await get(
        Uri.parse("${getUrl()}reports/stats/erteam/$erid"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 203) {
        var d = json.decode(response.body);

        setState(() {
          total = d['total'].toString();
          pending = d['newr'].toString();
          completed = d['complete'].toString();
          data = d["data"];
          isLoading = null;
        });
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

  checkIncomingCalls() {
    try {
      _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
        var nocalls = await storage.read(key: "incomingcalls");

        setState(() {
          incomingcalls =
              (nocalls.toString() == "null" ? "0" : nocalls.toString());
        });
      });
    } catch (e) {}
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
        title: const Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Home",
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
            decoration: const BoxDecoration(color: Colors.amber),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: RefreshIndicator(
                onRefresh: countTasks,
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
                                  builder: (_) => Pending(erid: erid)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.black87,
                              width: 1,
                            ),
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
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black87,
                            width: 1,
                          ),
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
                                    erid: erid,
                                  ),
                                ));
                              },
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.black87,
                                    width: 1,
                                  ),
                                ),
                                child: const Stack(
                                  children: [
                                    Text(
                                      "New Calls",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
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
                            width: 16,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Complete(erid: erid),
                                ));
                              },
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.black87,
                                    width: 1,
                                  ),
                                ),
                                child: const Stack(
                                  children: [
                                    Text(
                                      "Completed Calls",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
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
                            physics: NeverScrollableScrollPhysics(),
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
