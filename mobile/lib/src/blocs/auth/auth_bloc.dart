import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'auth_validators.dart';
import '../../constants/guest_user.dart';
import '../../models/user_model.dart';

class AuthBloc with AuthValidators {
  final _email = BehaviorSubject<String>();
  final _username = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  // final _submitError = BehaviorSubject<String>();
  final _user = BehaviorSubject<UserModel>();

  AuthBloc() {
    initBloc();
  }

  initBloc() async {
    final UserModel existingUser = await verifyJwt();

    if (existingUser == null) {
      _user.sink.add(GUEST_USER);
      return false;
    }

    _user.sink.add(existingUser);
    return true;
  }

  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changeUsername => _username.sink.add;
  Function(String) get changePassword => _password.sink.add;
  // Function(String) get changeSubmitError => _submitError.sink.add;

  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get username => _username.stream.transform(validateUsername);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream<UserModel> get user => _user.stream;

  // Broadcast allows for tabview changes to listen as many times as desired
  Stream<bool> get signupValid =>
      Rx.combineLatest3(email, username, password, (em, us, pw) => true)
          .asBroadcastStream();

  Stream<bool> get loginValid =>
      Rx.combineLatest2(username, password, (us, pw) => true)
          .asBroadcastStream();

  UserModel get currentUser => _user.value;

  Future<void> logout() async {
    print('Logging out... !');
    await deleteJwt();
    _user.sink.add(GUEST_USER);
  }

  Future<bool> submitAndLogin() async {
    final UserModel existingUser = await validateLogin(<String, dynamic>{
      'username': '${_username.value}',
      'password': '${_password.value}'
    });

    if (existingUser == null) {
      _user.sink.add(GUEST_USER);
      return false;
    }

    _user.sink.add(existingUser);
    return true;
  }

  Future<bool> submitAndSignup() async {
    final UserModel existingUser = await validateSignup(<String, dynamic>{
      'email': '${_email.value}',
      'username': '${_username.value}',
      'password': '${_password.value}'
    });

    if (existingUser == null) {
      _user.sink.add(GUEST_USER);
      return false;
    }

    _user.sink.add(existingUser);
    return true;
  }

  dispose() {
    _email.close();
    _username.close();
    _password.close();
    _user.close();
  }
}
