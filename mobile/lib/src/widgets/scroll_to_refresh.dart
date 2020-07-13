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
// TODO: Should I use this or not!?
// This should serve well for Search Screen
// // TODO: Include some widget that tells users they can swipe down to
// // refresh. As a result, this may become a full-fledged ListView.
// return Stack(children: [
//   // RefreshIndicator(
//   //     onRefresh: () async =>
//   //         await Future.delayed(Duration(seconds: 1)),
//   // child: ListView(
//   ListView(
//     children: [
//       // scrollToRefreshWidget(),
//       // Divider(height: 200.0, color: Colors.transparent),
//       NoAppointments(),
//     ],
//   ),
//   // ),
