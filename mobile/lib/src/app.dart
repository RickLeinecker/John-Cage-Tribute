import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/screens/dashboard.dart';

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return RoomProvider(
      child: SearchProvider(
        child: AuthProvider(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Dashboard(),
            title: 'John Cage Tribute',
            theme: appTheme(),
          ),
        ),
      ),
    );
  }

  ThemeData appTheme() {
    return ThemeData(
      primaryColor: Colors.blue[800],
      accentColor: Colors.blue[700],
      highlightColor: Colors.blue[900],
      fontFamily: 'Cambria',
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 30.0,
          color: Colors.white,
        ),
        bodyText1: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
        bodyText2: TextStyle(
          fontSize: 20.0,
          color: Colors.blue[100],
        ),
        subtitle1: TextStyle(
          fontSize: 16.0,
          color: Colors.blue[100],
        ),
        subtitle2: TextStyle(
          fontSize: 20.0,
          color: Colors.grey[600],
        ),
      ),
      unselectedWidgetColor: Colors.blue[300],
    );
  }
}
