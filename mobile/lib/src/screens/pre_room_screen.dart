import 'package:flutter/material.dart';
import 'package:jct/src/blocs/room/bloc.dart';

import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/loading_user.dart';
import 'package:jct/src/screens/room_screen.dart';

class PreRoomScreen extends StatelessWidget {
  final Stream<UserModel> user;

  PreRoomScreen({@required this.user});

  Widget build(context) {
    RoomBloc bloc = RoomProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Audio Recording Disclaimer',
        ),
      ),
      body: StreamBuilder(
        stream: user,
        builder: (context, AsyncSnapshot<UserModel> snapshot) {
          if (!snapshot.hasData) {
            return LoadingUser();
          }

          return Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Use of this application for recording copyrighted material may result in serious legal consequences. We of John Cage Tribute\'s team are not liable for such behavior. Use this application at your own risk.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  RaisedButton(
                    onPressed: () =>
                        loadRoomScreen(context, bloc, snapshot.data),
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'I Agree',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void loadRoomScreen(BuildContext context, RoomBloc bloc, UserModel user) {
    bloc.connectSocket();

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) {
          return RoomScreen(user: user);
        },
      ),
    );
  }
}
