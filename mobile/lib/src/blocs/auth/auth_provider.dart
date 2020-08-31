import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/auth_bloc.dart';

class AuthProvider extends InheritedWidget {
  final bloc = AuthBloc();

  AuthProvider({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static AuthBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>().bloc;
  }
}
