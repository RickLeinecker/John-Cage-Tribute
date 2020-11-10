import 'package:flutter/material.dart';
import 'package:jct/src/constants/pin_metadata.dart';

import 'package:jct/src/constants/role.dart';
import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/models/room_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/session_screen.dart';
import 'package:jct/src/widgets/role_buttons.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class RoomTile extends StatelessWidget {
  final UserModel user;
  final RoomModel room;

  RoomTile({@required this.user, @required this.room});

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return Card(
      child: Container(
        color: Theme.of(context).accentColor,
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Host: ${room.host}',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Text(
                'Performers: ${room.currentPerformers}/${room.maxPerformers}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                'Listeners: ${room.currentListeners}/${room.maxListeners}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
          onTap: () {
            onTilePressed(context, bloc);
          },
        ),
      ),
    );
  }

  void onTilePressed(BuildContext context, RoomBloc bloc) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          backgroundColor: Colors.teal,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          children: [
            Column(
              children: [
                Text(
                  'Joining a \nroom?',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 35.0,
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
                            style: TextStyle(color: Colors.teal),
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
          PinCodeTextField(
            appContext: context,
            enablePinAutofill: false,
            backgroundColor: Colors.teal,
            keyboardType: TextInputType.number,
            length: PIN_LENGTH,
            onChanged: null,
            onCompleted: (pin) => bloc.verifyPin(room.id, pin),
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
