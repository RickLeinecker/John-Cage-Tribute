import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String email;
  final String username;

  @override
  List<Object> get props => [email, username];

  UserModel.fromJson(Map<String, dynamic> parsedJson)
      : email = parsedJson['email'],
        username = parsedJson['name'];

  const UserModel({this.email, this.username});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'email': email, 'name': username};
  }
}
