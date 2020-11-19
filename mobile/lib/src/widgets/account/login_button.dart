import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';

class LoginButton extends StatelessWidget {
  Widget build(context) {
    AuthBloc bloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: bloc.loginValid,
      builder: (context, snapshot) {
        return Column(
          children: [
            StreamBuilder(
              stream: bloc.authSubmit,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return Text(
                  snapshot.hasError ? snapshot.error : '',
                  style: TextStyle(
                    color: Colors.red[700],
                  ),
                );
              },
            ),
            RaisedButton(
              onPressed: snapshot.hasData ? () => onLogin(context, bloc) : null,
              color: Theme.of(context).textTheme.bodyText1.color,
              textColor: Colors.cyan[900],
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void onLogin(BuildContext context, AuthBloc bloc) async {
    bool success = await bloc.submitAndLogin();

    if (success) {
      print('Login successful!');
    } else {
      print('Login error, bub.');
    }
  }
}
