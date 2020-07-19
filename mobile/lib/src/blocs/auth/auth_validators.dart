import 'dart:async';
import 'package:email_validator/email_validator.dart';
import '../../models/user_model.dart';
import '../../resources/user_api_retriever.dart';
import '../../../src/constants/guest_user.dart';

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
    if (EmailValidator.validate(enteredEmail) == false) {
      sink.addError('Invalid email.');
    } else {
      sink.add(enteredEmail);
    }
  });

  final validateUsername = StreamTransformer<String, String>.fromHandlers(
      handleData: (enteredUsername, sink) {
    final RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]{3,}$');
    if (_alphanumeric.hasMatch(enteredUsername)) {
      sink.addError('Username must be alphanumeric and at least 3 characters.');
    }
    sink.add(enteredUsername);
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (enteredPassword, sink) {
      final RegExp capLetterNumberSixDigits =
          RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');

      if (capLetterNumberSixDigits.hasMatch(enteredPassword)) {
        sink.add(enteredPassword);
      } else {
        sink.addError(
            'Must be 6 characters, have lowercase and capital letters, and digits.');
      }
    },
  );
}
