import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'auth_validators.dart';
import '../../constants/guest_user.dart';
import '../../models/user_model.dart';

class AuthBloc with AuthValidators {
  final _email = BehaviorSubject<String>();
  final _username = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _confirmPassword = BehaviorSubject<String>();
  final _submitLogin = BehaviorSubject<String>();
  final _submitSignup = BehaviorSubject<String>();
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
  Function(String) get changeConfirmPassword => _confirmPassword.sink.add;

  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get username => _username.stream.transform(validateUsername);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream<String> get confirmPassword => _confirmPassword.stream;
  Stream<UserModel> get user => _user.stream;
  Stream<String> get submitLogin => _submitLogin.stream;
  Stream<String> get submitSignup => _submitSignup.stream;

  // Broadcast allows for tabview changes to listen as many times as desired
  Stream<bool> get signupValid =>
      Rx.combineLatest4(email, username, password, confirmPassword,
          (em, us, pw, cpw) {
        if (pw == cpw) {
          return true;
        } else {
          _confirmPassword.sink.addError('Passwords do not match.');
        }
      }).asBroadcastStream();

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
    final parsedJson = await validateLogin(
      <String, dynamic>{
        'username': '${_username.value}',
        'password': '${_password.value}'
      },
    );

    if (parsedJson['username'] == null) {
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
        'email': '${_email.value}',
        'username': '${_username.value}',
        'password': '${_password.value}',
        'confirmPassword': '${_confirmPassword.value}'
      },
    );

    if (parsedJson['username'] == null) {
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
    _email.close();
    _username.close();
    _password.close();
    _confirmPassword.close();
    _user.close();
    _submitLogin.close();
    _submitSignup.close();
  }
}
