import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';

class ConfirmPasswordField extends StatelessWidget {
  Widget build(context) {
    AuthBloc bloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: bloc.confirmPassword,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          obscureText: true,
          onChanged: bloc.changeConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm the password above.',
            errorText: snapshot.error,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          ),
        );
      },
    );
  }
}
