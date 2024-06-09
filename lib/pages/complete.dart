// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:miledrivers/components/NewCallItem.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Complete extends StatefulWidget {
  final String driverid;
  const Complete({super.key, required this.driverid});

  @override
  State<Complete> createState() => _CompleteState();
}

class _CompleteState extends State<Complete> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> data = [];
  String incomingcalls = "";
  var isLoading;

  @override
  void initState() {
    fetchResolvedCalls();
    super.initState();
  }

  Future<void> fetchResolvedCalls() async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white, size: 100);
      });
      final response = await get(
        Uri.parse("${getUrl()}trips/status/Completed"),
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Complete Calls",
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
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 247, 211, 103)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return NewCallItem(item: data[index], index: index);
                          })),
                ],
              )),
            ),
          ),
          Center(
            child: isLoading,
          )
        ],
      ),
    );
  }
}
