import 'package:flutter/material.dart';

import 'package:jct/src/widgets/account/email_field.dart';
import 'package:jct/src/widgets/account/login_button.dart';
import 'package:jct/src/widgets/account/password_field.dart';

class LoginView extends StatelessWidget {
  Widget build(context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Container(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(color: Colors.transparent, height: 20.0),
                Text(
                  'Get your persona going.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                EmailField(),
                PasswordField(),
                LoginButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
