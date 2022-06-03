import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moc_2022/analytics_manager.dart';
import 'package:moc_2022/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("Coucou"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _logEvent(context),
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
}
