class User {
  final String firstName;
  final String lastName;
  final int age;

  User({
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json["firstName"],
      lastName: json["lastName"],
      age: json["age"],
    );
  }
}
