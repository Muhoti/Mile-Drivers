// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/pages/Login.dart';
import 'package:miledrivers/pages/SOS.dart';
import 'package:miledrivers/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', 'MY FOREGROUND SERVICE',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 3), (timer) async {
    compareData();
  });
}

Future<void> compareData() async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const storage = FlutterSecureStorage();

    final response = await get(
      Uri.parse("${getUrl()}reports/count/status/Received"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var data = json.decode(response.body);
    var incomingcalls = data["total"];
    await storage.write(key: "incomingcalls", value: incomingcalls.toString());

    print("new client calls are $incomingcalls");
    if (incomingcalls > 0) {
      await storage.write(key: "clientcall", value: "on");
      var notice = await storage.read(key: "clientcall");

      print("notice : $notice");

      flutterLocalNotificationsPlugin.show(
        888,
        'Ambulex Emergency',
        "Client Call Alert!",
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'my_foreground', 'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small', ongoing: false, onlyAlertOnce: true),
        ),
      );
    } else {
      print("main page incoming calls : $incomingcalls");
    }
  } catch (e) {
    print("nothing $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = const FlutterSecureStorage();
  bool permission = false;
  String erid = '';
  String name = '';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    _checkLocationPermission();

    super.initState();
  }

  Future<void> _checkLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.status;
      if (status.isGranted) {
        authenticateUser();
        setState(() {
          permission = true;
        });
      } else {
        setState(() {
          permission = false;
        });
      }
    } catch (e) {
      setState(() {
        permission = false;
      });
    }
  }

  Future<void> authenticateUser() async {
    try {
      var token = await storage.read(key: "mdjwt");
      var decoded = decodeJwtToken(token.toString());

      if (decoded == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Login()));
      } else {
        erid = decoded['ERTeamID'];
        name = decoded['Name'];

        print("name: $name, erid: $erid");

        await storage.write(key: "erid", value: erid);
        var alert = await storage.read(key: "clientcall");

        if (alert == 'on') {
          print("alert is $alert");
          flutterLocalNotificationsPlugin.cancel(0);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const SOS(item: null,)));
        } else {
          print("alert is $alert");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const Home()));
        }
      }
    } catch (e) {
        print("alert is $e");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Login()));
    }
  }

  Future<void> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        authenticateUser();
      } else if (status == PermissionStatus.denied) {
        openAppSettings();
      } else {
        openAppSettings();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
             color: Colors.amber),
          child: Column(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 24, 48, 0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 200, // Set the desired width
                      ),
                    ),
                    const Text(
                      'Mile Driver',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, color: Colors.black87),
                    ),
                    const Text(
                      'My Drive, My Pride',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    if (!permission)
                      TextButton(
                          onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Location Permission'),
                                  content: const Text(
                                      'This app collects location data to enable route navigation to various assets'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        requestLocationPermission();
                                        Navigator.pop(context, 'OK');
                                      },
                                      child: const Text('Grant Permissions'),
                                    ),
                                  ],
                                ),
                              ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Text(
                              "Review App Permissions",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ))
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
