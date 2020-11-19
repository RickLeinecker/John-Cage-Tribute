import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';

class SignupButton extends StatelessWidget {
  Widget build(context) {
    AuthBloc bloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: bloc.signupValid,
      builder: (context, snapshot) {
        return Column(
          children: [
            StreamBuilder(
              stream: bloc.authSubmit,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return Text(
                  snapshot.hasError ? snapshot.error : '',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                );
              },
            ),
            RaisedButton(
              onPressed:
                  snapshot.hasData ? () => onSignup(context, bloc) : null,
              color: Theme.of(context).textTheme.bodyText1.color,
              textColor: Theme.of(context).primaryColor,
              child: Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  void onSignup(BuildContext context, AuthBloc bloc) async {
    bool success = await bloc.submitAndSignup();

    if (success) {
      print('Signup successful!');
    } else {
      print('Signup error, bud.');
    }
  }
}
