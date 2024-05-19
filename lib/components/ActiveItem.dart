import 'dart:convert';

import 'package:ambulexdesign/components/Utils.dart';
import 'package:ambulexdesign/pages/Routing.dart';
import 'package:ambulexdesign/pages/SOS.dart';
import 'package:ambulexdesign/pages/clientdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ActiveItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  const ActiveItem({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<ActiveItem> createState() => _CollectedItemState();
}

class _CollectedItemState extends State<ActiveItem> {
  Map<String, dynamic> data = {};
  final storage = const FlutterSecureStorage();

  @override
  initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('${getUrl()}auth/${widget.item["UserID"]}'));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
        print("complete $data");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {}
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => Routing(
                      item: widget.item,
                    )));
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 96, 177, 1), // Cream color
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: 60,
                    decoration: BoxDecoration(
                        color: widget.item["Type"] == "GBV"
                            ? Colors.orange
                            : Colors.deepOrange,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                            color: const Color.fromARGB(50, 54, 193, 163),
                            width: 1)),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        (widget.item["Type"]).toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item["Name"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "${widget.item["Phone"]}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "${widget.item["City"]}, ${widget.item["Address"]}, ${widget.item["Landmark"]}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
                  decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(5))),
                  child: Text(
                    "${DateFormat('EEEE, MMMM d, y').format(parsePostgresTimestamp(widget.item["createdAt"]))} \n ${DateFormat('HH:mm').format(parsePostgresTimestamp(widget.item["createdAt"]))}",
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ))),
          const Positioned(
              right: 8,
              bottom: 24,
              child: Row(
                children: [
                  Text(
                    "Start Trip",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Icon(
                    Icons.forward,
                    color: Colors.white60,
                  )
                ],
              )),
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

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
    );
  }
}
