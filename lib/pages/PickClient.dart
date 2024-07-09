// ignore_for_file: library_private_types_in_public_api, unused_field, use_build_context_synchronously, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:mile_taxi_driver/components/Utils.dart';
import 'package:mile_taxi_driver/components/mydrawer.dart';
import 'package:mile_taxi_driver/pages/routing.dart';
import 'package:mile_taxi_driver/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PickClient extends StatefulWidget {
  final dynamic item;
  const PickClient({super.key, required this.item});

  @override
  State<PickClient> createState() => _PickClientState();
}

class _PickClientState extends State<PickClient> {
  GoogleMapController? _mapController;
  final storage = const FlutterSecureStorage();
  bool _isDialogOpen = true;
  double mylat = 0.0;
  double mylon = 0.0;
  late LatLng _dialogLocation; // Default location (San Francisco)
  late LatLng _userLocation; // User's location
  late LatLng _sampleLocation; // Sample location
  final MarkerId _userMarkerId = const MarkerId('user');
  final MarkerId _sampleMarkerId = const MarkerId('sample');
  dynamic isLoading;
  bool _isVisible = false;
  Map<String, dynamic> mydata = {};

  double clon = 0.0;
  double clat = 0.0;
  String status = "";
  String location = '';
  int distance = 5000;
  late String driverid;

  @override
  void initState() {
    super.initState();
    loadDriverID();
    loadDriverLocation();

    setState(() {
      _dialogLocation = LatLng(clat, clon);
      _sampleLocation = LatLng(clat, clon);
      _userLocation = LatLng(clon, clon);
    });
  }

  loadDriverID() async {
    try {
      var id = await storage.read(key: "driverid");

      setState(() {
        driverid = id.toString();
      });
    } catch (e) {}
  }

  loadDriverLocation() async {
    var loc = _determinePosition();
    loc.then((value) {
      setState(() {
        mylat = value.latitude;
        mylon = value.longitude;
        _userLocation = LatLng(mylat, mylon);
      });

      if (widget.item != null) {
        print("the PickClient data: ${widget.item}");
        setState(() {
          mydata = widget.item;
        });

        LatLng newlatlang = LatLng(double.parse(widget.item["FromLatitude"]),
            double.parse(widget.item["FromLongitude"]));
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: newlatlang, zoom: 17)));
      } else {
        getClientCall(mylon, mylat);
      }
    });
  }

  getClientCall(double mylon, double mylat) async {
    try {
      final response = await get(
        Uri.parse("${getUrl()}trips/nearby/$mylon/$mylat/$distance"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      List<dynamic> data = json.decode(response.body);

      if (data.isNotEmpty) {
        setState(() {
          mydata = data[0];
        });
        LatLng newlatlang = LatLng(double.parse(data[0]["Latitude"]),
            double.parse(data[0]["Longitude"]));
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: newlatlang, zoom: 17)));
      }
    } catch (e) {
      print(e);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  double _degreesToRadians(degrees) {
    return degrees * math.pi / 180;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the Earth in meters

    // Convert degrees to radians
    double lat1Radians = _degreesToRadians(lat1);
    double lon1Radians = _degreesToRadians(lon1);
    double lat2Radians = _degreesToRadians(lat2);
    double lon2Radians = _degreesToRadians(lon2);

    // Haversine formula
    double dLat = lat2Radians - lat1Radians;
    double dLon = lon2Radians - lon1Radians;

    double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1Radians) *
            math.cos(lat2Radians) *
            math.pow(math.sin(dLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    // Calculate the distance
    double distance = earthRadius * c;
    return distance;
  }

  void _showDialogLocation(LatLng location) {
    setState(() {
      _dialogLocation = location;
    });
    _toggleDialog();
  }

  void _toggleDialog() {
    setState(() {
      _isDialogOpen = !_isDialogOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Client PickClient",
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Client PickClient",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const Home()));
                },
                child: const Icon(Icons.arrow_back),
              )
            ],
          ),
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        drawer: const Drawer(child: MyDrawer()),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:
                    _userLocation, // Initial camera position at user's location
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: _userMarkerId,
                  position: _userLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                  infoWindow: const InfoWindow(
                    title: 'Driver Location',
                    snippet: 'Tap for details',
                  ),
                ),
                Marker(
                  markerId: _sampleMarkerId,
                  position: _sampleLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                  infoWindow: const InfoWindow(
                    title: 'Client Location',
                    snippet: '',
                  ),
                ),
              },
              onTap: _showDialogLocation,
            ),
            AnimatedPositioned(
              left: 0,
              right: 0,
              curve: Curves.easeInOut,
              bottom: _isVisible ? 0 : 0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    // Swipe down
                    setState(() {
                      _isVisible = false;
                    });
                  } else {
                    // Swipe up
                    setState(() {
                      _isVisible = true;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Colors.amber,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Incoming Call',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (mydata.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xffF6F5F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Material(
                                    color: Colors.orange,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                mydata.isNotEmpty
                                                    ? mydata["ClientName"]
                                                    : "",
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                mydata.isNotEmpty
                                                    ? mydata["ClientPhone"]
                                                    : "",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(width: 12),
                                  // Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     Text(
                                  //       DateFormat('EEEE, MMMM d, y').format(
                                  //           parsePostgresTimestamp(
                                  //               mydata["createdAt"])),
                                  //       style: const TextStyle(
                                  //         fontSize: 16,
                                  //         fontWeight: FontWeight.w400,
                                  //       ),
                                  //     ),
                                  //     const SizedBox(height: 6),
                                  //     Text(
                                  //       DateFormat('HH:mm').format(
                                  //           parsePostgresTimestamp(
                                  //               mydata["createdAt"])),
                                  //       style: const TextStyle(
                                  //         fontSize: 16,
                                  //         fontWeight: FontWeight.w400,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF6F5F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Are you free? Pick the request below",
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.green,
                                    child: InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isLoading = LoadingAnimationWidget
                                              .staggeredDotsWave(
                                            color: Colors.blue,
                                            size: 100,
                                          );
                                        });

                                        acceptCall(mydata["TripID"], driverid);

                                        storage.write(
                                            key: "clientcall", value: "off");
                                        storage.write(
                                            key: "notification", value: "off");
                                        storage.write(
                                            key: "clat",
                                            value: clat.toString());
                                        storage.write(
                                            key: "clon",
                                            value: clon.toString());

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    Routing(item: mydata)));
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Accept",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Material(
                                    color: Colors.deepOrange,
                                    child: InkWell(
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        setState(() {
                                          isLoading = LoadingAnimationWidget
                                              .staggeredDotsWave(
                                            color: Colors.blue,
                                            size: 100,
                                          );
                                        });
                                        // clearStorage();

                                        storage.write(
                                            key: "clientcall", value: "off");
                                        storage.write(
                                            key: "notification", value: "on");

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => const Home()));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  acceptCall(String tripid, String driverid) async {
    storage.write(key: "clientcall", value: "off");

    final response = await put(
      Uri.parse("${getUrl()}trips/update/$tripid"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <dynamic, dynamic>{'ClientStatus': 'Picked', 'DriverID': driverid}),
    );

    // await clearStorage();

    if (response.statusCode == 200 || response.statusCode == 203) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      return Message(
        token: null,
        success: null,
        error: "Connection to server failed!",
      );
    }
  }

  Future<void> clearStorage() async {
    storage.write(key: "clientcall", value: "off");
    storage.write(key: "notification", value: "off");

    String? alert = storage.read(key: "notification").toString();
    print("alert PickClient is $alert");
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
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
