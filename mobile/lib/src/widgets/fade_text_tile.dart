import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FadeTextTile extends StatelessWidget {
  final String title;
  final String body;

  FadeTextTile({this.title, this.body});

  Widget build(context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Text(
              '$title',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '$body',
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
          Divider(height: 20.0, color: Colors.transparent),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
