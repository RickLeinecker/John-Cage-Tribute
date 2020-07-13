import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pin_put/pin_put.dart';
import '../../src/constants/role.dart';
import '../blocs/room/bloc.dart';
import '../models/room_model.dart';
import '../screens/session_screen.dart';
import '../widgets/role_buttons.dart';

class RoomTile extends StatelessWidget {
  final String joiningUser;
  final RoomModel room;

  RoomTile({@required this.joiningUser, @required this.room});

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
    ));
  }

  void onTilePressed(BuildContext context, RoomBloc bloc) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          backgroundColor: Theme.of(context).accentColor,
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
                  height: 30.0,
                ),
                Text(
                  'Please enter ${room.host}\'s PIN code:',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                StreamBuilder(
                    stream: bloc.pin,
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      return PinPut(
                        autofocus: true,
                        controller: bloc.pinText,
                        inputDecoration: InputDecoration(
                          fillColor: Colors.white,
                          errorText: snapshot.hasError ? snapshot.error : null,
                        ),
                        fieldsCount: 4,
                        onChanged: (pin) {
                          bloc.validateExistingPin(room.id, pin);
                        },
                      );
                    }),
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
                  stream: bloc.joinRoomValid,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    return RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text('Join',
                          style: Theme.of(context).textTheme.bodyText2),
                      onPressed: snapshot.hasData
                          ? () => onJoinRoom(context, bloc, room, joiningUser)
                          : null,
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

  Future<void> onJoinRoom(BuildContext context, RoomBloc bloc, RoomModel room,
      String joiningUser) async {
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

    bloc.joinRoom(room.id, joiningUser);
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SessionScreen(
              user: joiningUser, roomId: room.id, isHost: false);
        },
      ),
    );
  }
}
