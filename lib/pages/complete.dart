import 'dart:convert';

import 'package:ambulexdesign/components/NewCallItem.dart';
import 'package:ambulexdesign/components/Utils.dart';
import 'package:ambulexdesign/components/mydrawer.dart';
import 'package:ambulexdesign/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Complete extends StatefulWidget {
  final String erid;
  const Complete({super.key, required this.erid});

  @override
  State<Complete> createState() => _CompleteState();
}

class _CompleteState extends State<Complete> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> clientCalls = [];
  var isLoading;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    fetchResolvedCalls();
    super.initState();
  }

  Future<void> fetchResolvedCalls() async {
    setState(() {
      isLoading = LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.orange,
        size: 100,
      );
    });
    try {
      final response = await get(
        Uri.parse(
            "${getUrl()}reportsntasks/paginated/Resolved/${widget.erid}/0"),
      );

      List responseList = json.decode(response.body);
      setState(() {
        clientCalls = responseList;
        isLoading = null;
      });
      print("Data sent is $clientCalls");
    } catch (e) {
      isLoading = null;
      print(e);
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
        backgroundColor: const Color.fromRGBO(0, 96, 177, 1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 96, 177, 1),
                Color.fromRGBO(0, 96, 177, 1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (clientCalls.isEmpty && isLoading == null) {
      return const Center(
        child: Text('No client calls.'),
      );
    } else {
      return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: clientCalls.length,
          itemBuilder: (context, index) {
            return NewCallItem(
              item: clientCalls[index],
              index: index,
            );
          });
    }
  }
}
