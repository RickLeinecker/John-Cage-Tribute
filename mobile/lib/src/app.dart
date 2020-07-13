import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'blocs/auth/bloc.dart';
import 'blocs/room/bloc.dart';
import 'screens/dashboard.dart';

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return AuthProvider(
      child: RoomProvider(
        child: MaterialApp(
          title: 'John Cage Tribute',
          home: Dashboard(),
          onGenerateRoute: routes,
          theme: appTheme(),
        ),
      ),
    );
  }

  ThemeData appTheme() {
    return ThemeData(
      primaryColor: Colors.blue[800],
      accentColor: Colors.blue[700],
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
      ),
      unselectedWidgetColor: Colors.blue[300],
    );
  }

  Route routes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(builder: (context) {
          return Dashboard();
        });
      // Invalid screen
      default:
        return CupertinoPageRoute(builder: (context) {
          return Text('ERROR SCREEN!!!!!!!');
        });
    }
  }
}
