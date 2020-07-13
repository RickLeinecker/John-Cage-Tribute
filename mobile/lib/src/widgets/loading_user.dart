import 'package:flutter/material.dart';

class LoadingUser extends StatelessWidget {
  Widget build(context) {
    return SizedBox.expand(
      child: Container(
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.supervised_user_circle,
                  color: Theme.of(context).accentColor, size: 50.0),
              Text(
                'Please wait while we\n authenticate you...',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Divider(
                color: Colors.transparent,
                height: 40.0,
              ),
              CircularProgressIndicator(),
            ],
          )),
    );
  }
}
