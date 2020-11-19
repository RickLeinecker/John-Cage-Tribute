import 'package:flutter/material.dart';

import 'package:jct/src/widgets/account/confirm_password_field.dart';
import 'package:jct/src/widgets/account/email_field.dart';
import 'package:jct/src/widgets/account/signup_button.dart';
import 'package:jct/src/widgets/account/password_field.dart';
import 'package:jct/src/widgets/account/username_field.dart';

class SignupView extends StatelessWidget {
  Widget build(context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Container(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tired of acting as a guest?\nSign up below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            EmailField(),
            Divider(color: Colors.transparent, height: 5.0),
            UsernameField(),
            Divider(color: Colors.transparent, height: 5.0),
            PasswordField(),
            Divider(color: Colors.transparent, height: 5.0),
            ConfirmPasswordField(),
            SignupButton(),
          ],
        ),
      ],
    );
  }
}
