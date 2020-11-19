import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';

class UsernameField extends StatelessWidget {
  Widget build(context) {
    AuthBloc bloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: bloc.username,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          onChanged: bloc.changeUsername,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Three or more letters or numbers.',
            errorText: snapshot.error,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          ),
        );
      },
    );
  }
}
