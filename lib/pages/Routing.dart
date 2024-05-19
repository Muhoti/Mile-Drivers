import 'dart:convert';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:miledrivers/components/mydrawer.dart';
import 'package:miledrivers/pages/FileReport.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class Routing extends StatefulWidget {
  final dynamic item;
  const Routing({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  Marker? sourcePosition, destinationPosition;
  LocationData? _currentPosition;
  late BitmapDescriptor _vehicleIcon;
  LatLng curLocation = const LatLng(-1.2940491, 36.8076449);
  StreamSubscription<LocationData>? locationSubscription;
  bool _isVisible = false;
  bool routing = false;
  String html_instructions = "";
  String distance = "";
  String duration = "";
  String maneuver = "";
  String small_duration = "";
  String small_distance = "";

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  @override
  void didUpdateWidget(covariant Routing oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  initializeServices() async {
    _vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/car.png',
    );
    _getCurrentLocation();
    addMarker(_vehicleIcon);
  }

  void _getCurrentLocation() async {
    try {
      geolocator.Position position =
          await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      setState(() {
        curLocation = LatLng(position.latitude!, position.longitude!);
        sourcePosition = Marker(
          markerId: MarkerId(position.toString()),
          icon: _vehicleIcon,
          position: LatLng(position.latitude!, position.longitude!),
          anchor: const Offset(0.5, 0.5),
        );
      });
      LatLng destination = LatLng(double.parse(widget.item["Latitude"]),
          double.parse(widget.item["Longitude"]));

      double d = calculateDistance(
          curLocation.latitude,
          curLocation.longitude,
          double.parse(widget.item["Latitude"]),
          double.parse(widget.item["Longitude"]));

      print("ltt $d");
      if (d > 50) {
        _updateCameraPosition(curLocation, 10, 0);
        getDirections(destination);
      } else {
        _updateCameraPosition(curLocation, 18, 0);
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateCameraPosition(
      LatLng newPosition, double zoom, double newRotation) async {
    try {
      final GoogleMapController? controller = await _controller.future;
      await controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: zoom,
            bearing: newRotation,
          ),
        ),
      );
    } catch (e) {}
  }

  getNavigation(BitmapDescriptor _vehicleIcon) async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      final GoogleMapController? controller = await _controller.future;
      location.changeSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10);
      _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      if (_permissionGranted == PermissionStatus.granted) {
        _currentPosition = await location.getLocation();
        curLocation =
            LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
        locationSubscription =
            location.onLocationChanged.listen((LocationData currentLocation) {
          if (mounted) {
            setState(() {
              curLocation =
                  LatLng(currentLocation.latitude!, currentLocation.longitude!);
              sourcePosition = Marker(
                markerId: MarkerId(currentLocation.toString()),
                icon: _vehicleIcon,
                position: LatLng(
                    currentLocation.latitude!, currentLocation.longitude!),
                anchor: const Offset(0.5, 0.5),
              );
            });

            double d = calculateDistance(
                curLocation.latitude,
                curLocation.longitude,
                double.parse(widget.item["Latitude"]),
                double.parse(widget.item["Longitude"]));

            if (d > 50) {
              getDirections(LatLng(double.parse(widget.item["Latitude"]),
                  double.parse(widget.item["Longitude"])));
              getNavigationInstructions(LatLng(
                  double.parse(widget.item["Latitude"]),
                  double.parse(widget.item["Longitude"])));
            } else {
              _updateCameraPosition(curLocation, 18, 0);
              setState(() {
                routing = true;
                maneuver = "arrive";
                small_distance = "Arrived";
                html_instructions =
                    "<b>You have Arrived!</b> <br> You are less than 50 meters from the patient";
              });
            }
          }
        });
      }
    } catch (e) {}
  }

  getDirections(LatLng dst) async {
    try {
      List<LatLng> polylineCoordinates = [];
      List<dynamic> points = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          'AIzaSyAuvt2CB5r1jLoA5k00VnDkJmrAM3cL52g',
          PointLatLng(curLocation.latitude, curLocation.longitude),
          PointLatLng(dst.latitude, dst.longitude),
          travelMode: TravelMode.driving);

      setState(() {
        distance = result.distance!;
        duration = result.duration!;
      });

      if (result.points.isNotEmpty) {
        if (result.points.length > 1 && routing) {
          PointLatLng point0 = result.points[0];
          PointLatLng point1 = result.points[1];
          double bearing = calculateHeading(
              LatLng(point0.latitude, point0.longitude),
              LatLng(point1.latitude, point1.longitude));
          _updateCameraPosition(curLocation, 18, bearing);
        }

        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          points.add({'lat': point.latitude, 'lng': point.longitude});
        });
      } else {
        print(result.errorMessage);
      }
      addPolyLine(polylineCoordinates);
    } catch (e) {}
  }

  double calculateHeading(LatLng from, LatLng to) {
    // Convert coordinates from degrees to radians
    double fromLat = from.latitude * math.pi / 180;
    double fromLng = from.longitude * math.pi / 180;
    double toLat = to.latitude * math.pi / 180;
    double toLng = to.longitude * math.pi / 180;

    // Calculate bearing using Haversine formula
    double deltaLng = toLng - fromLng;
    double y = math.sin(deltaLng) * math.cos(toLat);
    double x = math.cos(fromLat) * math.sin(toLat) -
        math.sin(fromLat) * math.cos(toLat) * math.cos(deltaLng);
    double bearing = math.atan2(y, x);

    // Convert bearing from radians to degrees
    bearing = bearing * 180 / math.pi;

    // Normalize the bearing to be in the range [0, 360]
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  Future<void> getNavigationInstructions(LatLng dst) async {
    try {
      double originLat = curLocation.latitude; // Origin latitude
      double originLng = curLocation.longitude; // Origin longitude
      double destinationLat = dst.latitude; // Destination latitude
      double destinationLng = dst.longitude; // Destination longitude
      String apiKey = 'AIzaSyAuvt2CB5r1jLoA5k00VnDkJmrAM3cL52g';

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$apiKey&steps=true';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<dynamic> routes = data['routes'];
          if (routes.isNotEmpty) {
            List<dynamic> steps = routes[0]['legs'][0]['steps'];
            print("mydata ${steps[0]}");
            setState(() {
              html_instructions = steps[0]["html_instructions"];
              small_duration = steps[0]["duration"]["text"];
              small_distance = steps[0]["distance"]["text"];
              maneuver = steps[0]["maneuver"];
            });
          }
        }
      } else {
        print('Failed to fetch directions');
      }
    } catch (e) {}
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
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
        cos(lat1Radians) * cos(lat2Radians) * math.pow(math.sin(dLon / 2), 2);
    double c = 2 * math.atan2(sqrt(a), sqrt(1 - a));

    // Calculate the distance
    double distance = earthRadius * c;
    return distance;
  }

  addMarker(BitmapDescriptor _vehicleIcon) {
    setState(() {
      sourcePosition = Marker(
        markerId: const MarkerId('source'),
        position: curLocation,
        icon: _vehicleIcon,
      );
      destinationPosition = Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(double.parse(widget.item["Latitude"]),
            double.parse(widget.item["Longitude"])),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    });
  }

  IconData _getMeneuverIcon(String mn) {
    print("mydata-mane $mn");
    switch (mn) {
      case 'turn-left':
        return Icons.turn_left;
      case 'turn-right':
        return Icons.turn_right;
      case 'turn-slight-left':
        return Icons.turn_slight_left;
      case 'turn-slight-right':
        return Icons.turn_slight_right;
      case 'turn-sharp-left':
        return Icons.turn_sharp_left;
      case 'turn-sharp-right':
        return Icons.turn_sharp_right;
      case 'merge':
        return Icons.merge;
      case 'fork-left':
        return Icons.fork_left;
      case 'fork-right':
        return Icons.fork_right;
      case 'ramp-left':
        return Icons.trending_down;
      case 'ramp-right':
        return Icons.trending_up;
      case 'keep-left':
        return Icons.straight;
      case 'keep-right':
        return Icons.straight;
      case 'roundabout-left':
        return Icons.roundabout_left;
      case 'roundabout-right':
        return Icons.roundabout_right;
      case 'uturn-left':
        return Icons.u_turn_left;
      case 'uturn-right':
        return Icons.u_turn_right;
      case 'straight':
        return Icons.straight;
      case 'depart':
        return Icons.trip_origin;
      case 'arrive':
        return Icons.flag;
      default:
        return Icons.straight;
    }
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          title: Row(
            children: [
              const Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Routing",
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
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 96, 177, 1),
                    Color.fromRGBO(0, 96, 177, 1)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                child: Stack(
                  children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      polylines: Set<Polyline>.of(polylines.values),
                      initialCameraPosition: CameraPosition(
                        target: curLocation,
                        zoom: 18,
                      ),
                      markers:
                          sourcePosition != null && destinationPosition != null
                              ? {sourcePosition!, destinationPosition!}
                              : {},
                      onTap: (latLng) {
                        print(latLng);
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                    !routing
                        ? AnimatedPositioned(
                            left: 0,
                            right: 0,
                            curve: Curves.easeInOut,
                            bottom: _isVisible ? 0 : -350,
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
                                        topRight: Radius.circular(30)),
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          50, 0, 50, 12),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 226, 226, 226),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        height: 10,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                          color: Color(0xffF6F5F2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 0, 12),
                                            child: Text(
                                              'Customer Details',
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                widget.item["Name"],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.gps_fixed,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "${widget.item["City"]}, ${widget.item["Address"]}, ${widget.item["Landmark"]}, ${widget.item["BuildingName"]}, ${widget.item["HouseNumber"]},",
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Material(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 1)),
                                                  child: InkWell(
                                                    onTap: () {
                                                      _makePhoneCall("tel",
                                                          widget.item["Phone"]);
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.phone,
                                                            color: Colors.blue,
                                                          ),
                                                          Expanded(
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                "Call",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Expanded(
                                                child: Material(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 1)),
                                                  child: InkWell(
                                                    onTap: () {
                                                      _makePhoneCall("sms",
                                                          widget.item["Phone"]);
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.sms,
                                                            color: Colors.blue,
                                                          ),
                                                          Expanded(
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                "Chat",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                softWrap: true,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                          color: Color(0xffF6F5F2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Material(
                                            color: widget.item["Type"] == "GBV"
                                                ? Colors.orange
                                                : Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                widget.item["Type"],
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "${DateFormat('EEEE, MMMM d, y').format(parsePostgresTimestamp(widget.item["createdAt"]))} \n${DateFormat('HH:mm').format(parsePostgresTimestamp(widget.item["createdAt"]))}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                          color: Color(0xffF6F5F2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Trip Details: $distance - $duration",
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Icon(
                                                Icons.directions_car,
                                                size: 44,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Expanded(
                                                child: TextButton(
                                                    onPressed: () {
                                                      double d = calculateDistance(
                                                          curLocation.latitude,
                                                          curLocation.longitude,
                                                          double.parse(
                                                              widget.item[
                                                                  "Latitude"]),
                                                          double.parse(widget
                                                                  .item[
                                                              "Longitude"]));

                                                      if (d > 50) {
                                                        setState(() {
                                                          routing = true;
                                                        });
                                                        getNavigation(
                                                            _vehicleIcon);
                                                      } else {
                                                        setState(() {
                                                          routing = true;
                                                          maneuver = "arrive";
                                                          small_distance =
                                                              "Arrived";
                                                          html_instructions =
                                                              "<b>You have Arrived!</b> <br> You are less than 50 meters from the patient";
                                                        });
                                                      }

                                                      print(d);
                                                    },
                                                    style: const ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Colors.blue)),
                                                    child: const Text(
                                                      "Start Trip",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                          color: Color(0xffF6F5F2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const Icon(
                                            Icons.map,
                                            size: 44,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: TextButton(
                                                onPressed: () async {
                                                  await launchUrl(Uri.parse(
                                                      'google.navigation:q=${widget.item["Latitude"]}, ${widget.item["Longitude"]}&key=AIzaSyAuvt2CB5r1jLoA5k00VnDkJmrAM3cL52g'));
                                                },
                                                style: const ButtonStyle(
                                                    side:
                                                        MaterialStatePropertyAll(
                                                            BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 1)),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors
                                                                .transparent)),
                                                child: const Text(
                                                  "Get Directions on Google Map",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                          color: Color(0xffF6F5F2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Customer served? Submit a report below",
                                            softWrap: true,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              FileReport(
                                                                  clientId: widget
                                                                          .item[
                                                                      "ID"])));
                                                },
                                                style: const ButtonStyle(
                                                    side:
                                                        MaterialStatePropertyAll(
                                                            BorderSide(
                                                                color: Colors
                                                                    .orange,
                                                                width: 1)),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors
                                                                .transparent)),
                                                child: const Text(
                                                  "File Report",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : AnimatedPositioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            duration: const Duration(milliseconds: 0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                color: const Color.fromARGB(255, 255, 255, 255),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey
                                        .withOpacity(0.5), // Shadow color
                                    spreadRadius: 5, // Spread radius
                                    blurRadius: 7, // Blur radius
                                    offset: const Offset(0,
                                        3), // Offset from the top-left corner
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      "Trip Details: $distance - $duration",
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Icon(
                                                _getMeneuverIcon(maneuver),
                                                size: 44,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                small_duration,
                                                softWrap: true,
                                              ),
                                              Text(
                                                small_distance,
                                                softWrap: true,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 5, // Adjust flex value as needed
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xffF6F5F2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: SingleChildScrollView(
                                            // Wrap with SingleChildScrollView to handle overflow
                                            child: html.Html(
                                              data: html_instructions,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                routing = false;
                                              });
                                              locationSubscription?.cancel();
                                            },
                                            child: const Icon(
                                              Icons.close_rounded,
                                              size: 32,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  Future<void> _makePhoneCall(String scheme, String phoneNumber) async {
    try {
      if (scheme == "tel") {
        canLaunchUrl(Uri(scheme: scheme, path: phoneNumber))
            .then((bool result) async {
          if (result) {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: phoneNumber,
            );
            await launchUrl(launchUri);
          }
        });
      } else {
        final Uri smsLaunchUri = Uri(
          scheme: 'sms',
          path: phoneNumber.replaceFirst(RegExp(r'^.'), '+254'),
          queryParameters: <String, String>{
            'body': 'Hi, hold on. I am on the way!',
          },
        );
        await launchUrl(smsLaunchUri);
      }
    } catch (e) {}
  }
}
