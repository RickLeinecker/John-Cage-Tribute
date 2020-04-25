import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  TextEditingController _controller;

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 350,
          height: 35,
          alignment: Alignment.center,
            // constraints: BoxConstraints(
            //   maxHeight: 30,
            //   maxWidth: 350,
            //   minWidth: 30,
            //   minHeight: 20,
            // ),
          child: Text(
            'Search a Composition',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        actions: <Widget>[
          
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }
}

// class CompSearchDelegate extends SearchDelegate {

// }