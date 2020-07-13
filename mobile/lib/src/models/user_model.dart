import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String email;
  final String username;
  final String password;

  @override
  List<Object> get props => [email, username, password];

  UserModel.fromJson(Map<String, dynamic> parsedJson)
      : email = parsedJson['email'],
        username = parsedJson['username'],
        password = parsedJson['password'];

  const UserModel({this.email, this.username, this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'username': username,
      'password': password,
    };
  }
}
