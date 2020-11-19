import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';

class PasswordField extends StatelessWidget {
  Widget build(context) {
    AuthBloc bloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: bloc.password,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          obscureText: true,
          onChanged: bloc.changePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '6+ characters. Use capitals and numbers.',
            errorText: snapshot.error,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          ),
        );
      },
    );
  }
}
