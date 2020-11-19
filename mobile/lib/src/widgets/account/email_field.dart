import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';

class EmailField extends StatelessWidget {
  Widget build(context) {
    AuthBloc bloc = AuthProvider.of(context);
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return TextField(
          onChanged: bloc.changeEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'johndoe@example.com',
            errorText: snapshot.error,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          ),
        );
      },
    );
  }
}
