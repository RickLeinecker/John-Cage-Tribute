import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  Widget build(context) {
    return SizedBox.expand(
      child: Container(
          color: Theme.of(context).primaryColor,
          child: Center(
              child: Text(
            'Library Screen',
            textAlign: TextAlign.center,
          ))),
    );
  }
}
