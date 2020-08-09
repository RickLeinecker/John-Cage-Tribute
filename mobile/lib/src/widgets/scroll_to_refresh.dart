import 'package:flutter/material.dart';

class ScrollToRefresh extends StatelessWidget {
  Widget build(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Swipe here',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText2.color,
              fontSize: 10.0,
              fontFamily: 'Cambria',
            )),
        Icon(Icons.arrow_downward,
            color: Theme.of(context).accentColor, size: 30.0),
        Text('to refresh',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText2.color,
              fontSize: 10.0,
              fontFamily: 'Cambria',
            )),
      ],
    );
  }
}
