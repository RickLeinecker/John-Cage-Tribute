import 'package:flutter/material.dart';

class NoResults extends StatelessWidget {
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.mood_bad, size: 80.0, color: Theme.of(context).accentColor),
        Text('Whoops! No search meeting your criteria was found...',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center),
      ],
    );
  }
}
