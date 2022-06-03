import 'dart:async';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moc_2022/add_user_screen.dart';
import 'package:moc_2022/analytics_manager.dart';
import 'package:moc_2022/bo/user.dart';
import 'package:moc_2022/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runZonedGuarded<Future<void>>(() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    runApp(const MaterialApp(home: Home()));
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnalyticsManager(
        analyticsInterface: FirebaseAnalyticsImplementation(),
        child: const Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              default:
                if (snapshot.hasError) {
                  return Text("Erreur ! ${snapshot.error}");
                }

                final QuerySnapshot? querySnapshot = snapshot.data;
                final List<QueryDocumentSnapshot>? documentsSnapshots = querySnapshot?.docs;

                if (documentsSnapshots == null || documentsSnapshots.isEmpty) {
                  return const Text("No users");
                }

                return ListView.builder(
                  itemCount: documentsSnapshots.length,
                  itemBuilder: (BuildContext context, int index) {
                    final User user = User.fromJson(
                      documentsSnapshots[index].data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      title: Text("${user.firstName} ${user.lastName}"),
                      subtitle: Text("Age: ${user.age}"),
                    );
                  },
                );
            }
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _crashApp,
            child: const Icon(Icons.bug_report),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _addUser(context),
          ),
        ],
      ),
    );
  }

  void _logEvent(BuildContext context) {
    AnalyticsManager.of(context).logEvent(
      "button_clicked_toto",
      params: {
        "randomKey": "randomValue",
      },
    );
  }

  void _addUser(BuildContext context) async {
    AddUserScreen.navigateTo(context);
  }

  void _crashApp() {
    //FirebaseCrashlytics.instance.crash();
    //throw Exception("SALUT, ceci est un crash de test");

    try {
      _getFakeDataFromNetwork();
    } catch (exception, stackstrace) {
      // UI logic
      // ...

      FirebaseCrashlytics.instance.recordError(
        exception,
        stackstrace,
      );
    }
  }

  Future<void> _getFakeDataFromNetwork() {
    throw Exception("OUPS, Server Error");
  }

  void _initFirebaseMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: false,
    );

    await _initLocalNotifications();
    _lookForMessagingToken();

    FirebaseMessaging.onMessage.listen((message) => _onMessage(message, onForeground: true));
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);
  }

  Future<void> _initLocalNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onNotificationClicked,
    );
  }

  void _onNotificationClicked(String? payload) {
    print("Local notification clicked !");
  }

  void _onMessage(RemoteMessage message, {bool onForeground = false}) async {
    final AndroidNotification? android = message.notification?.android;
    final RemoteNotification? notification = message.notification;

    print("_onMessage: $message");
    if (notification != null && android != null && onForeground) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: android.smallIcon,
          ),
        ),
      );
    }
  }

  void _onNotificationOpenedApp(RemoteMessage message) async {
    print("Une notification a ouvert l'application ! ${message.notification?.title}");
  }

  void _lookForMessagingToken() async {
    final String? token = await FirebaseMessaging.instance.getToken();
    print("Firebase Messaging Token : $token");
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print("Firebase Messaging Token : $token");
    });
  }
}
