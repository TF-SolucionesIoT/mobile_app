class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String typeOfUser;
  final String username;
  final String password;
  final String gender;
  final String createdAt;


  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.typeOfUser,
    required this.username,
    required this.password,
    required this.gender,
    required this.createdAt  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        typeOfUser: json['type_of_user'],
        username: json['username'],
        password: json['password'],
        gender: json['gender'],
        createdAt: json['created_at'],
      );
}
