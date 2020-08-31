import 'package:flutter/material.dart';

class NotRegistered extends StatelessWidget {
  Widget build(context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.no_meeting_room,
              size: 80.0, color: Theme.of(context).accentColor),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          Text(
              'Our apologies, but only registered users may access this screen.\n\nPlease make an account to access your compositions!',
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
