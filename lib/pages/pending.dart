import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:miledrivers/components/NewCallItem.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:miledrivers/components/Utils.dart';

class Pending extends StatefulWidget {
  final String driverid;
  const Pending({Key? key, required this.driverid}) : super(key: key);

  @override
  State<Pending> createState() => _PendingState();
}

class _PendingState extends State<Pending> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  List<dynamic> data = [];
  double distanceFilterKm = 10;
  var isLoading;
  bool _isFirstLoad = true;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    checkGps();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {});
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    fetchIncomingCalls(position.latitude, position.longitude);
  }

  Future<void> fetchIncomingCalls(double latitude, double longitude) async {
    if (_isFirstLoad) {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.amber,
          size: 100,
        );
      });
    }
    try {
      double distanceFilterMeters = distanceFilterKm * 1000;

      final response = await get(
        Uri.parse(
          "${getUrl()}trips/nearby/$latitude/$longitude/${distanceFilterMeters.toInt()}",
        ),
      );

      List responseList = json.decode(response.body);
      setState(() {
        data = responseList;
        isLoading = null;
        _isFirstLoad = false;
      });
      print("Data sent is $data");
    } catch (e) {
      setState(() {
        isLoading = null;
        _isFirstLoad = false;
      });
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
                "Incoming Calls",
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: const BoxDecoration(color: Colors.white),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Filter Customers By Distance (km)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        onChanged: (value) {
                          setState(() {
                            distanceFilterKm = double.tryParse(value) ?? 0;
                          });
                          if (!_isFirstLoad) {
                            getLocation();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: isLoading ?? const SizedBox(),
                ),
                const SizedBox(height: 24,),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (data.isEmpty && isLoading == null) {
      return const Center(
        child: Text('No client calls.'),
      );
    } else {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return NewCallItem(
            item: data[index],
            index: index,
          );
        },
      );
    }
  }
}
