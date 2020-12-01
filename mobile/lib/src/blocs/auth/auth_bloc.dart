import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:jct/src/blocs/auth/auth_validators.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/user_model.dart';

class AuthBloc with AuthValidators {
  final _email = BehaviorSubject<String>();
  final _username = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _confirmPassword = BehaviorSubject<String>();
  final _authSubmit = BehaviorSubject<bool>();
  final _deletingAccount = BehaviorSubject<bool>();
  final _user = BehaviorSubject<UserModel>();

  AuthBloc() {
    initBloc();
  }

  initBloc() async {
    final UserModel existingUser = await verifyJwt();
    _user.sink.add(existingUser == GUEST_USER ? GUEST_USER : existingUser);
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
  Stream<bool> get authSubmit => _authSubmit.stream;
  Stream<bool> get deletingAccount => _deletingAccount.stream;

  Stream<bool> get signupValid =>
      Rx.combineLatest4(email, username, password, confirmPassword,
          (em, us, pw, cpw) {
        if (em != null && us != null && pw != null && cpw != null) {
          if (pw == cpw) {
            return true;
          } else {
            _confirmPassword.sink.addError('Passwords do not match.');
          }
        }
      }).asBroadcastStream();

  Stream<bool> get loginValid => Rx.combineLatest2(email, password, (em, pw) {
        if (em != null && pw != null) {
          return true;
        }
      }).asBroadcastStream();

  UserModel get currentUser => _user.value;

  void clearFields() {
    _username.sink.add(null);
    _email.sink.add(null);
    _password.sink.add(null);
    _confirmPassword.sink.add(null);
    _authSubmit.sink.add(null);
  }

  Future<void> logout() async {
    print('Logging out... !');
    await deleteJwt();
    clearFields();
    _user.sink.add(GUEST_USER);
  }

  Future<bool> submitAndLogin() async {
    _user.sink.add(null);

    final parsedJson = await validateLogin(
      <String, dynamic>{
        'email': '${_email.value}',
        'password': '${_password.value}'
      },
    );

    if (parsedJson['statusCode'] != 200) {
      _user.sink.add(GUEST_USER);
      _authSubmit.sink.addError(parsedJson['error']);
      return false;
    }

    final existingUser = UserModel.fromJson(parsedJson);

    _user.sink.add(existingUser);
    _authSubmit.sink.add(true);
    return true;
  }

  Future<bool> submitAndSignup() async {
    _user.sink.add(null);

    final parsedJson = await validateSignup(
      <String, dynamic>{
        'email': '${_email.value}',
        'name': '${_username.value}',
        'password': '${_password.value}',
        'confirmPassword': '${_confirmPassword.value}',
      },
    );

    if (parsedJson['statusCode'] != 200) {
      _user.sink.add(GUEST_USER);
      _authSubmit.sink.addError(parsedJson['error']);
      return false;
    }

    final existingUser = UserModel.fromJson(parsedJson);
    _user.sink.add(existingUser);
    _authSubmit.sink.add(true);
    return true;
  }

  Future<bool> deleteAccount() async {
    print('Attempting to delete account... !');

    if (_user.value == GUEST_USER) {
      print('Silly guest, account deletion is for users!');
      _deletingAccount.sink.addError('Guests cannot delete themselves.');
      return false;
    }

    _deletingAccount.sink.add(true);

    bool deleteSuccess = await validateDeleteAccount();

    if (deleteSuccess) {
      _deletingAccount.sink.add(false);
      await logout();
      return true;
    } else {
      _deletingAccount.sink.addError('An error occurred while deleting your '
          'account. Please try again later.');
      return false;
    }
  }

  void dispose() {
    _email.close();
    _username.close();
    _password.close();
    _confirmPassword.close();
    _user.close();
    _authSubmit.close();
    _deletingAccount.close();
  }
}
