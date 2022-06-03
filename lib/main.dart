import 'package:cloud_firestore/cloud_firestore.dart';
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
        onPressed: _addUser,
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

  void _addUser() async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection(
      "users/TOTO/friends",
    );

    try {
      final DocumentReference ref = await usersCollection.add({
        "firstName": "Bob",
        "lastName": "Dylan",
        "age": 42,
      });

      /*usersCollection.doc("TOTO").set({
        "firstName": "toto",
        "lastName": "tata",
        "age": 42,
      });*/

      //print("User added : ${ref.id}");
    } catch (error) {
      print(error);
    }
  }
}
