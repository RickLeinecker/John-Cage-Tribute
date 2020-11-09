import 'dart:async';
import 'package:email_validator/email_validator.dart';

import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/models/status_model.dart';
import 'package:jct/src/resources/user_api_retriever.dart';
import 'package:jct/src/constants/guest_user.dart';

class AuthValidators {
  static final _userApiRetriever = UserApiRetriever();

  Future<UserModel> verifyJwt() async {
    final parsedJson = await _userApiRetriever.jwtOrEmpty;

    if (parsedJson != null) {
      return UserModel.fromJson(parsedJson);
    } else {
      return GUEST_USER;
    }
  }

  Future<void> deleteJwt() async {
    await _userApiRetriever.storage.delete(key: 'jwt');
  }

  Future<bool> validateDeleteAccount() async {
    final response = await _userApiRetriever.deleteUserAndCompositions();

    print('Response while deleting account:');
    print('Code: ${response.code}\nMessage: ${response.message}');

    return response.code == 200 ? true : false;
  }

  Future<Map<String, dynamic>> validateSignup(Map<String, dynamic> user) async {
    final parsedJson = await _userApiRetriever.signup(user);
    return parsedJson;
  }

  Future<Map<String, dynamic>> validateLogin(Map<String, dynamic> user) async {
    final parsedJson = await _userApiRetriever.login(user);
    return parsedJson;
  }

  final validateEmail = StreamTransformer<String, String>.fromHandlers(
      handleData: (enteredEmail, sink) async {
    if (enteredEmail != null &&
        EmailValidator.validate(enteredEmail) == false) {
      sink.addError('Invalid email.');
    } else {
      sink.add(enteredEmail);
    }
  });

  final validateUsername = StreamTransformer<String, String>.fromHandlers(
      handleData: (enteredUsername, sink) {
    final RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]{3,}$');
    if (enteredUsername != null && _alphanumeric.hasMatch(enteredUsername)) {
      sink.addError('Username must be alphanumeric and at least 3 characters.');
    }
    sink.add(enteredUsername);
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (enteredPassword, sink) {
      final RegExp capitalNumberSixChars =
          RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');

      if (enteredPassword != null) {
        if (capitalNumberSixChars.hasMatch(enteredPassword)) {
          sink.add(enteredPassword);
        } else if (enteredPassword.isNotEmpty) {
          sink.addError(
              'Must be 6 characters, have lowercase and capital letters, and digits.');
        }
      }
    },
  );
}
