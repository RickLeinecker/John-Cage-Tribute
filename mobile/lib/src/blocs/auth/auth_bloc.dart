import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:jct/src/blocs/auth/auth_validators.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/user_model.dart';

class AuthBloc with AuthValidators {
  final _signupEmail = BehaviorSubject<String>();
  final _loginEmail = BehaviorSubject<String>();
  final _username = BehaviorSubject<String>();
  final _signupPassword = BehaviorSubject<String>();
  final _loginPassword = BehaviorSubject<String>();
  final _confirmPassword = BehaviorSubject<String>();
  final _submitLogin = BehaviorSubject<String>();
  final _submitSignup = BehaviorSubject<String>();
  final _user = BehaviorSubject<UserModel>();

  AuthBloc() {
    initBloc();
  }

  initBloc() async {
    final UserModel existingUser = await verifyJwt();
    _user.sink.add(existingUser == GUEST_USER ? GUEST_USER : existingUser);
  }

  Function(String) get changeSignupEmail => _signupEmail.sink.add;
  Function(String) get changeLoginEmail => _loginEmail.sink.add;
  Function(String) get changeUsername => _username.sink.add;
  Function(String) get changeSignupPassword => _signupPassword.sink.add;
  Function(String) get changeLoginPassword => _loginPassword.sink.add;
  Function(String) get changeConfirmPassword => _confirmPassword.sink.add;

  Stream<String> get signupEmail =>
      _signupEmail.stream.transform(validateEmail);
  Stream<String> get loginEmail => _loginEmail.stream.transform(validateEmail);
  Stream<String> get username => _username.stream.transform(validateUsername);
  Stream<String> get loginPassword =>
      _loginPassword.stream.transform(validatePassword);
  Stream<String> get signupPassword =>
      _signupPassword.stream.transform(validatePassword);
  Stream<String> get confirmPassword => _confirmPassword.stream;
  Stream<UserModel> get user => _user.stream;
  Stream<String> get submitLogin => _submitLogin.stream;
  Stream<String> get submitSignup => _submitSignup.stream;

  // Broadcast allows for tabview changes to listen as many times as desired
  Stream<bool> get signupValid =>
      Rx.combineLatest4(signupEmail, username, signupPassword, confirmPassword,
          (em, us, pw, cpw) {
        if (pw == cpw) {
          return true;
        } else {
          _confirmPassword.sink.addError('Passwords do not match.');
        }
      }).asBroadcastStream();

  Stream<bool> get loginValid =>
      Rx.combineLatest2(loginEmail, loginPassword, (em, pw) => true)
          .asBroadcastStream();

  UserModel get currentUser => _user.value;

  Future<void> logout() async {
    print('Logging out... !');
    await deleteJwt();
    _user.sink.add(GUEST_USER);
  }

  Future<bool> submitAndLogin() async {
    final parsedJson = await validateLogin(
      <String, dynamic>{
        'email': '${_loginEmail.value}',
        'password': '${_loginPassword.value}'
      },
    );

    if (parsedJson['statusCode'] != 200) {
      _user.sink.add(GUEST_USER);
      _submitLogin.sink.addError(parsedJson['error']);
      return false;
    }

    final existingUser = UserModel.fromJson(parsedJson);
    _user.sink.add(existingUser);
    _submitLogin.sink.add('');
    return true;
  }

  Future<bool> submitAndSignup() async {
    final parsedJson = await validateSignup(
      <String, dynamic>{
        'email': '${_signupEmail.value}',
        'name': '${_username.value}',
        'password': '${_signupPassword.value}',
        'confirmPassword': '${_confirmPassword.value}',
      },
    );

    if (parsedJson['statusCode'] != 200) {
      _user.sink.add(GUEST_USER);
      _submitSignup.sink.addError(parsedJson['error']);
      return false;
    }

    final existingUser = UserModel.fromJson(parsedJson);
    _user.sink.add(existingUser);
    _submitSignup.sink.add('');
    return true;
  }

  dispose() {
    _signupEmail.close();
    _loginEmail.close();
    _username.close();
    _signupPassword.close();
    _loginPassword.close();
    _confirmPassword.close();
    _user.close();
    _submitLogin.close();
    _submitSignup.close();
  }
}
