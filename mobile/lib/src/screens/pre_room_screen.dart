import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/room_screen.dart';
import 'package:jct/src/widgets/loading_user.dart';

class PreRoomScreen extends StatelessWidget {
  final Stream<UserModel> user;

  PreRoomScreen({@required this.user});

  Widget build(context) {
    final bloc = RoomProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).accentColor,
        title: Text('Audio Recording Disclaimer'),
      ),
      body: StreamBuilder(
        stream: user,
        builder: (context, AsyncSnapshot<UserModel> snapshot) {
          if (!snapshot.hasData) {
            return LoadingUser();
          }

          return buildBody(context, bloc, snapshot.data);
        },
      ),
    );
  }

  Widget buildBody(BuildContext context, RoomBloc bloc, UserModel user) {
    const screenRatio = 0.7;

    return Stack(
      children: [
        SizedBox.expand(
          child: Container(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Center(
          child: Icon(
            Icons.warning,
            size: 120.0,
            color: Theme.of(context).accentColor,
          ),
        ),
        ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple,
                Colors.transparent,
                Colors.transparent,
                Colors.purple
              ],
              stops: [0.0, 0.1, 0.9, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: Padding(
            padding: EdgeInsets.only(
              left: 50.0,
              right: 50.0,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * screenRatio,
              child: ListView(
                children: [
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  Text(
                    'HALT!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 75.0,
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 35.0,
                  ),
                  Text(
                    'Before you continue, please be warned about this important note.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  Text(
                    'Use of this application for recording copyrighted material may result in serious legal consequences.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  Text(
                    'We of John Cage Tribute\'s team are not liable for such behavior.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  Text(
                    'Creativity is key for this app, but it too has limits. '
                    'Use its session feature at your own risk.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 30.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          heightFactor: 11.0,
          child: RaisedButton(
            onPressed: () => loadRoomScreen(context, bloc, user),
            color: Theme.of(context).textTheme.bodyText2.color,
            textColor: Theme.of(context).primaryColor,
            child: Text('I Agree'),
          ),
        ),
      ],
    );
  }

  void loadRoomScreen(BuildContext context, RoomBloc bloc, UserModel user) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) {
          bloc.connectSocket();
          return RoomScreen(user: user);
        },
      ),
    );
  }
}
