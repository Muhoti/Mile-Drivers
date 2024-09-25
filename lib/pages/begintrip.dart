import 'dart:convert';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:mile_driver/components/Utils.dart';
import 'package:mile_driver/components/mydrawer.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:mile_driver/pages/home.dart';
import 'package:mile_driver/pages/payhero.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt;
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class BeginTrip extends StatefulWidget {
  final dynamic item;
  const BeginTrip({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _BeginTripState createState() => _BeginTripState();
}

class _BeginTripState extends State<BeginTrip> {
  final storage = const FlutterSecureStorage();
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
  String cost = "";

  @override
  void initState() {
    super.initState();
    print("begin trip item: ${widget.item}");
    cost = widget.item["TripPrice"];
    initializeServices();
  }

  @override
  void didUpdateWidget(covariant BeginTrip oldWidget) {
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
        curLocation = LatLng(position.latitude, position.longitude);
        sourcePosition = Marker(
          markerId: MarkerId(position.toString()),
          icon: _vehicleIcon,
          position: LatLng(position.latitude, position.longitude),
          anchor: const Offset(0.5, 0.5),
        );
      });
      LatLng destination = LatLng(double.parse(widget.item["DestLatitude"]),
          double.parse(widget.item["DestLongitude"]));

      double d = calculateDistance(
          curLocation.latitude,
          curLocation.longitude,
          double.parse(widget.item["DestLatitude"]),
          double.parse(widget.item["DestLongitude"]));

      print("line 95 distance: $d");
      if (d > 20) {
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

  getNavigation(BitmapDescriptor vehicleIcon) async {
    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      location.changeSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10);
      serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      if (permissionGranted == PermissionStatus.granted) {
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
                icon: vehicleIcon,
                position: LatLng(
                    currentLocation.latitude!, currentLocation.longitude!),
                anchor: const Offset(0.5, 0.5),
              );
            });

            double d = calculateDistance(
                curLocation.latitude,
                curLocation.longitude,
                double.parse(widget.item["DestLatitude"]),
                double.parse(widget.item["DestLongitude"]));

            print("line 170 distance: $d");

            if (d > 20) {
              getDirections(LatLng(double.parse(widget.item["DestLatitude"]),
                  double.parse(widget.item["DestLongitude"])));
              getNavigationInstructions(LatLng(
                  double.parse(widget.item["DestLatitude"]),
                  double.parse(widget.item["DestLongitude"])));
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
      color: const Color.fromARGB(255, 23, 117, 126),
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
    const double earthRadius = 6371000;

    double _degreesToRadians(double degrees) {
      return degrees * math.pi / 180;
    }

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
    print("line 320 distance: $distance meters");
    return distance;
  }

  addMarker(BitmapDescriptor vehicleIcon) {
    setState(() {
      sourcePosition = Marker(
        markerId: const MarkerId('source'),
        position: curLocation,
        icon: vehicleIcon,
      );
      destinationPosition = Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(double.parse(widget.item["DestLatitude"]),
            double.parse(widget.item["DestLongitude"])),
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

  endTrip(String tripid) async {
    storage.write(key: "clientcall", value: "off");

    final response = await put(
      Uri.parse("${getUrl()}trips/update/$tripid"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{'ClientStatus': 'Completed'}),
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
                  textAlign: TextAlign.center,
                  "To Client's Destination",
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
                                              'Trip Details',
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                "Customer: ${widget.item["ClientName"]}",
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
                                                Icons.person,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                "Price: KSh.${widget.item["TripPrice"]}/-",
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
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "From: ${widget.item["ClientLocation"]}",
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
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
                                              const Icon(
                                                Icons.gps_fixed,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "To: ${widget.item["ClientDestination"]},",
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 6,
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
                                      child: Column(
                                        children: [
                                          Text(
                                            "Trip Duration: $distance - $duration",
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
                                                color: Colors.amber,
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
                                                          double.parse(widget
                                                                  .item[
                                                              "DestLatitude"]),
                                                          double.parse(widget
                                                                  .item[
                                                              "DestLongitude"]));

                                                      if (d > 20) {
                                                        print(
                                                            "line 685 distance is: $d");
                                                        setState(() {
                                                          routing = true;
                                                        });
                                                        getNavigation(
                                                            _vehicleIcon);
                                                      } else {
                                                        print(
                                                            "line 702 distance is: $d");
                                                        setState(() {
                                                          routing = true;
                                                          maneuver = "arrive";
                                                          small_distance =
                                                              "Arrived";
                                                          html_instructions =
                                                              "<b>You have Arrived!";
                                                        });
                                                      }

                                                      print(d);
                                                    },
                                                    style: const ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Colors.amber)),
                                                    child: const Text(
                                                      "Continue to destination",
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
                                            color: Colors.amber,
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
                                                                color: Colors
                                                                    .amber,
                                                                width: 1)),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors
                                                                .transparent)),
                                                child: const Text(
                                                  "Get Directions on Google Map",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.amber,
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
                                            "Arrived at Destination? End Trip Below",
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
                                                  endTrip(
                                                      widget.item["TripID"]);
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => PayHero(
                                                          tripCost:
                                                              double.parse(
                                                                  cost),
                                                          phone: widget.item[
                                                              "ClientPhone"],
                                                        ),
                                                      ));
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
                                                  "End Trip",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.amber,
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
                                          color: Colors.amber, fontSize: 16),
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
                                                color: Colors.amber,
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
                                              print("pressed x ");
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
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: TextButton(
                                        onPressed: () {
                                          endTrip(widget.item["TripID"]);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => PayHero(
                                                        tripCost:
                                                            double.parse(cost),
                                                        phone: widget.item[
                                                            "ClientPhone"],
                                                      )));
                                        },
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.amber)),
                                        child: const Text(
                                          "End Trip",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  )
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
