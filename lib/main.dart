import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(children: <Widget>[
          Text('Running on: $_platformVersion\n'),
          RaisedButton(child: Text("Add region"), onPressed: () {
            Geolocation location = Geolocation(latitude: 50.853410, longitude: 3.354470, radius: 50.0, id: "Kerkplein13");
            Geofence.addGeolocation(location, GeolocationEvent.entry).then((onValue) {
              print("great success");
              scheduleNotification("Georegion added", "Your geofence has been added!");
            }).catchError((onError) {
              print("great failure");
            });
          },),
          RaisedButton(child: Text("Add neighbour region"), onPressed: () {
            Geolocation location = Geolocation(latitude: 50.853440, longitude: 3.354490, radius: 50.0, id: "Kerkplein15");
            Geofence.addGeolocation(location, GeolocationEvent.entry).then((onValue) {
              print("great success");
              scheduleNotification("Georegion added", "Your geofence has been added!");
            }).catchError((onError) {
              print("great failure");
            });
          },),
          RaisedButton(child: Text("Remove regions"), onPressed: () {
            Geofence.removeAllGeolocations();
          },),
          RaisedButton(child: Text("Request Permissions"), onPressed: () {
            Geofence.requestPermissions();
          },),
          RaisedButton(child: Text("get user location"), onPressed: () {
            Geofence.getCurrentLocation().then((coordinate) {
              print("great got latitude: ${coordinate.latitude} and longitude: ${coordinate.longitude}");
            });
          }),
          RaisedButton(child: Text("Listen to background updates"), onPressed: () {
            Geofence.startListeningForLocationChanges();
            Geofence.backgroundLocationUpdated.stream.listen((event) {
              scheduleNotification("You moved significantly", "a significant location change just happened.");
            });
          }),
          RaisedButton(child: Text("Stop listening to background updates"), onPressed: () {
            Geofence.stopListeningForLocationChanges();
          }),

        ],
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    Geofence.initialize();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) {
      scheduleNotification("Exit of a georegion", "Byebye to: ${entry.id}");
    });
  }

  void scheduleNotification(String title, String subtitle) {
    print("scheduling one with $title and $subtitle");
    var rng = new Random();
    Future.delayed(Duration(seconds: 5)).then((result) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          rng.nextInt(100000), title, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }
}
