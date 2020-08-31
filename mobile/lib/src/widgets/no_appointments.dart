import 'package:flutter/material.dart';

import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/user_model.dart';

class NoAppointments extends StatelessWidget {
  final UserModel user;

  NoAppointments({@required this.user});

  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.speaker_notes_off,
            size: 80.0, color: Theme.of(context).accentColor),
        Text(
            'No aspiring musicians found here!${user == GUEST_USER ? '' : '\n Would you like to be one?'}',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center),
      ],
    );
  }
}
