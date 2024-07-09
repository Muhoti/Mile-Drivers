// ignore_for_file: file_names

import 'package:mile_taxi_driver/pages/PickClient.dart';
import 'package:mile_taxi_driver/pages/TripDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewCallItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  const NewCallItem({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<NewCallItem> createState() => _CollectedItemState();
}

class _CollectedItemState extends State<NewCallItem> {
  Map<String, dynamic> data = {};
  final storage = const FlutterSecureStorage();

  @override
  initState() {
    super.initState();
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.item["ClientStatus"] == "Incoming"
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PickClient(
                          item: widget.item,
                        )))
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TripDetails(
                          tripid: widget.item["TripID"],
                        )));
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 238, 238),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 32, 31, 31).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          " ${widget.item["ClientName"]}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "${widget.item["ClientPhone"]}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
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
                    "Client Location: ${widget.item["ClientLocation"]}",
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                  ))),
          Positioned(
              right: 8,
              bottom: 20,
              child: Icon(
                widget.item["Gender"] == "Female" ? Icons.female : Icons.male,
                size: 32,
                color: widget.item["Gender"] == "Female"
                    ? Colors.purple
                    : Colors.orange,
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
