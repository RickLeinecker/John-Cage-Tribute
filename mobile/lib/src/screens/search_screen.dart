import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget build(context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).accentColor,
              title: Container(
                width: 350,
                height: 40,
                // TODO: Make this its own widget, may be used later
                // Suggested named parameters: onSubmit, ...
                child: Container(
                  child: TextFormField(
                      controller: _textController,
                      cursorColor: Colors.tealAccent[400],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Compositions',
                        hintStyle: Theme.of(context).textTheme.bodyText1,
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => _textController.clear(),
                            color: Colors.blue[100]),
                      ),
                      style: Theme.of(context).textTheme.bodyText1,
                      onFieldSubmitted: (text) {
                        if (text != '') {
                          print('$text'); // TODO: Perform API call
                        }
                      }),
                  margin: EdgeInsets.only(left: 10.0),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 10.0,
                  children: [
                    RaisedButton(child: Text('Tags'), onPressed: () => {}),
                    RaisedButton(
                        child: Text('Composed By'), onPressed: () => {}),
                    RaisedButton(
                        child: Text('Performed By'), onPressed: () => {})
                  ],
                ),
              ),
            )),
        body: Stack(children: [
          SizedBox.expand(
            child: Container(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Icon(Icons.queue_music,
                    size: 120.0, color: Theme.of(context).accentColor),
                Text('Musical masterpieces will display here!',
                    textAlign: TextAlign.center)
              ]))
        ]));
  }

  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
