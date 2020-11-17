import 'package:flutter/material.dart';
import 'package:jct/src/constants/pin_metadata.dart';

import 'package:jct/src/constants/role.dart';
import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/models/room_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/session_screen.dart';
import 'package:jct/src/widgets/flashing_music_icon.dart';
import 'package:jct/src/widgets/role_buttons.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class RoomTile extends StatelessWidget {
  final UserModel user;
  final RoomModel room;

  RoomTile({@required this.user, @required this.room});

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    if (room.isClosed()) {
      return ListTile(
        tileColor: Colors.grey,
        enabled: false,
        title: Text(
          room.host,
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
        subtitle: Text('This room is closed.'),
        trailing: Icon(Icons.cancel_presentation),
      );
    }

    return ListTile(
      tileColor: Theme.of(context).accentColor,
      title: Text(
        room.host,
        style: TextStyle(
          fontSize: 30.0,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.mic),
          VerticalDivider(
            color: Colors.transparent,
            width: 5.0,
          ),
          Text(
            '${room.currentPerformers}/${room.maxPerformers}',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          VerticalDivider(
            color: Colors.transparent,
            width: 15.0,
          ),
          Icon(Icons.headset),
          VerticalDivider(
            color: Colors.transparent,
            width: 5.0,
          ),
          Text(
            '${room.currentListeners}/${room.maxListeners}',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
      trailing: Wrap(
        spacing: 18,
        children: <Widget>[
          room.hasPin ? Icon(Icons.lock) : SizedBox.shrink(),
          (room.sessionStarted ?? false)
              ? FlashingMusicIcon()
              : SizedBox.shrink(),
        ],
      ),
      onTap: () {
        onTilePressed(context, bloc);
      },
    );
  }

  void onTilePressed(BuildContext context, RoomBloc bloc) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          backgroundColor: Colors.cyan,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          title: Text(
            'Joining a room?',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          children: [
            Column(
              children: [
                Divider(
                  color: Colors.transparent,
                  height: 10.0,
                ),
                Text(
                  'What role will you play?',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                RoleButtons(),
                StreamBuilder(
                  stream: bloc.pinValid,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    return Column(
                      children: [
                        pinPrompt(context, bloc),
                        Visibility(
                          visible: snapshot.hasError ?? '',
                          child: Divider(
                            color: Colors.transparent,
                            height: 10.0,
                          ),
                        ),
                        Visibility(
                          visible: snapshot.hasError,
                          child: Text(
                            snapshot.error ?? '',
                            style: TextStyle(
                              color: Colors.red[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        RaisedButton(
                          color: Theme.of(context).textTheme.bodyText2.color,
                          child: Text(
                            'Join',
                            style: TextStyle(color: Colors.cyan),
                          ),
                          onPressed: !room.hasPin || snapshot.hasData
                              ? () => onJoinRoom(context, bloc)
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget pinPrompt(BuildContext context, RoomBloc bloc) {
    return Visibility(
      visible: room.hasPin,
      child: Column(
        children: [
          Divider(
            color: Colors.transparent,
            height: 30.0,
          ),
          Text(
            'Please enter ${room.host}\'s PIN code:',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
          Divider(
            color: Colors.transparent,
            height: 15.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: PinCodeTextField(
              appContext: context,
              backgroundColor: Colors.transparent,
              cursorColor: Colors.white,
              enablePinAutofill: false,
              keyboardType: TextInputType.number,
              length: PIN_LENGTH,
              onChanged: null,
              onCompleted: (pin) => bloc.verifyPin(room.id, pin),
              pinTheme: PinTheme(
                activeColor: Colors.lime,
                inactiveColor: Colors.white,
                shape: PinCodeFieldShape.box,
                selectedColor: Colors.lightBlueAccent[200],
              ),
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onJoinRoom(BuildContext context, RoomBloc bloc) async {
    if (bloc.currentRole == Role.PERFORMER) {
      print('Can confirm you\'re a performer!');
      if (!await Permission.microphone.request().isGranted) {
        print('Hmmm, you didn\'t grant the mic permission.');
        if (await Permission.microphone.isPermanentlyDenied) {
          print('Permanently denied, to boot!? Meanie!');
          openAppSettings();

          if (!await Permission.microphone.isGranted) {
            print('Ah, thanks for revoking the permanent denial there! :)');
            return;
          }
        } else {
          print('[host_button] (onCreateRoom) Mic permission denied.');
          return;
        }
      }
    }

    bloc.joinRoom(room.id, user.username);

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SessionScreen(
            user: user,
            roomId: room.id,
            isHost: false,
            role: bloc.currentRole,
          );
        },
      ),
    );
  }
}
