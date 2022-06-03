import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moc_2022/add_user_screen.dart';
import 'package:moc_2022/analytics_manager.dart';
import 'package:moc_2022/bo/user.dart';
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addUser(context),
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
}
