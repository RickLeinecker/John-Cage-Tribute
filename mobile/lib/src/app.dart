import 'package:flutter/material.dart';

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'John Cage Tribute',
      onGenerateRoute: routes,
    );
  }

  Route routes(RouteSettings settings) {
    switch (settings.name) {

      // TODO: Home Screen
      case '/':
        return MaterialPageRoute(
          builder: (context) {
            return Text('Bet?');
          }
        );

        // Invalid screen
      default:
        return MaterialPageRoute(
          builder: (context) {
            return Text('ERROR SCREEN!!!!!!!');
          }
        );
    }
  }
}