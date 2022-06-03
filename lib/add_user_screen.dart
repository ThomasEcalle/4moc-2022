import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddUserScreen extends StatelessWidget {
  static void navigateTo(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return AddUserScreen();
      },
    ));
  }

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _lastNameController,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text("Add user"),
              onPressed: _addUser,
            ),
          ],
        ),
      ),
    );
  }

  void _addUser() async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection(
      "users",
    );

    try {
      final DocumentReference ref = await usersCollection.add({
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "age": num.parse(_ageController.text),
      });

      print("User added : ${ref.id}");
    } catch (error) {
      print(error);
    }
  }
}
