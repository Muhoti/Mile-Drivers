import 'package:miledrivers/pages/sos.dart';
import 'package:miledrivers/pages/TripDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

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
                    builder: (_) => SOS(
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
                color: Colors.amber, // Cream color
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
                        color: Colors.orange,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                            color: const Color.fromARGB(50, 54, 193, 163),
                            width: 1)),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.item["TripPrice"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                          widget.item["ClientName"],
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
                          "${widget.item["ClientPhone"]}",
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
                          "${widget.item["DestLatitude"]}, ${widget.item["DestLongitude"]}",
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
