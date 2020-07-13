import 'dart:async';
import 'package:email_validator/email_validator.dart';
import '../../models/user_model.dart';
import '../../resources/user_api_retriever.dart';

class AuthValidators {
  static final _userApiRetriever = UserApiRetriever();

  Future<UserModel> verifyJwt() async {
    final UserModel returningUser = await _userApiRetriever.jwtOrEmpty;
    return returningUser;
  }

  Future<void> deleteJwt() async {
    await _userApiRetriever.storage.delete(key: 'jwt');
  }

  Future<UserModel> validateSignup(Map<String, dynamic> user) async {
    final UserModel newUser = await _userApiRetriever.signup(user);
    return newUser;
  }

  Future<UserModel> validateLogin(Map<String, dynamic> user) async {
    final UserModel returningUser = await _userApiRetriever.login(user);

    return returningUser;
  }

  final validateEmail = StreamTransformer<String, String>.fromHandlers(
      handleData: (enteredEmail, sink) async {
    if (EmailValidator.validate(enteredEmail) == false) {
      sink.addError('Invalid email.');
    }

    List<String> emailList = await _userApiRetriever.fetchEmailList();
    for (String existingEmail in emailList) {
      if (enteredEmail == existingEmail) {
        sink.addError('This email is already taken.');
        return;
      }
    }
    sink.add(enteredEmail);
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
          'Must be 6 characters, have lowercase, capital, and digits.');
    }
  });
}
