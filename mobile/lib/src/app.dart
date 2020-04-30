import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'screens/dashboard.dart';
import 'screens/search_screen.dart';

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    // return WillPopScope(
    //   onWillPop: () => _onBackPressed(context),
    return MaterialApp(
      // child: PlatformApp(
      title: 'John Cage Tribute',
      home: Dashboard(),
      // onGenerateRoute: routes,
      theme: appTheme(),
      // ),
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
          fontSize: 18.0,
          color: Colors.blue[100],
        ),
        bodyText2: TextStyle(
          fontSize: 20.0,
          color: Colors.blue[100],
        ),
      ),
      unselectedWidgetColor: Colors.blue[300],
      iconTheme: IconThemeData(), // TODO: Add icon theme data
    );
  }

  Route routes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) {
          return Dashboard();
        });

      case '/search':
        return MaterialPageRoute(builder: (context) {
          return SearchScreen();
        });
      // Invalid screen
      default:
        return MaterialPageRoute(builder: (context) {
          return Text('ERROR SCREEN!!!!!!!');
        });
    }
  }
}
