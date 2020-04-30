import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  createState() => AppointmentScreenState();
}

class AppointmentScreenState extends State<AppointmentScreen> {
  Future<bool> _oneSec;

  initState() {
    super.initState();
    _oneSec = Future.delayed(Duration(seconds: 1), () => true);
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Appointments',
        ),
        backgroundColor: Theme.of(context).accentColor,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return FutureBuilder(
        future: _oneSec,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.expand(
              child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))),
            );
          }

          // TODO: Include some widget that tells users they can swipe down to
          // refresh. As a result, this may become a full-fledged ListView.
          return Stack(children: [
            RefreshIndicator(
                onRefresh: () async =>
                    await Future.delayed(Duration(seconds: 1)),
                child: ListView(
                  children: [
                    scrollToRefreshWidget(),
                    Divider(height: 200.0, color: Colors.transparent),
                    noAppointmentsWidget(),
                    // Divider(height: 200.0, color: Colors.transparent),
                  ],
                )
                // child: Stack(
                //   children: [
                //     Center(
                //       child: scrollToRefreshWidget(),
                //       // child: noAppointmentsWidget(),
                //     ),
                //     ListView(),
                //   ],
                // ),
                ),
            Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 10.0,
              child: RaisedButton.icon(
                  textColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).textTheme.bodyText2.color,
                  icon: Icon(Icons.add),
                  label: Text('Host a Room'),
                  onPressed: () => print('Host button pressed!')),
              // onPressed: () => onHostButtonPressed()),
            )
          ]);
        });
  }

  // void onHostButtonPressed() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return Dialog(
  //             backgroundColor: Theme.of(context).accentColor,
  //             child: SizedBox.expand(
  //                 child: RaisedButton(
  //               child: Text('Sup'),
  //               onPressed: () {},
  //             )));
  //       });
  // }

  Widget scrollToRefreshWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TODO: Add this to app's theme in app.dart
        Text('Swipe down',
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

  Widget noAppointmentsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.speaker_notes_off,
            size: 80.0, color: Theme.of(context).accentColor),
        Text('No aspiring musicians found here!\n Would you like to be one?',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center),
      ],
    );
  }
}
