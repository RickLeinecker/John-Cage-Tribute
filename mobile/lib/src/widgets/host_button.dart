import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/constants/role_limits.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/session_screen.dart';
import 'package:jct/src/widgets/role_buttons.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:pinput/pin_put/pin_put.dart';

// TODO: Why the heck is iOS crashing when it makes a new room? Wtf.
class HostButton extends StatelessWidget {
  final UserModel user;

  HostButton({@required this.user});

  Widget build(BuildContext context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return Container(
        child: RaisedButton.icon(
      textColor: Theme.of(context).primaryColor,
      color: Theme.of(context).textTheme.bodyText2.color,
      icon: Icon(Icons.add),
      label: Text('Host a Room'),
      onPressed: (user == GUEST_USER)
          ? null
          : () => onHostButtonPressed(context, bloc),
    ));
  }

  void onHostButtonPressed(BuildContext context, RoomBloc bloc) {
    showDialog(
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
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                Text(
                  'Before you begin...',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 35.0,
                ),
                Text(
                  'How many performers \nwould you like?',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 5.0,
                ),
                StreamBuilder(
                  stream: bloc.numPerformers,
                  builder: (context, AsyncSnapshot<int> snapshot) {
                    return DropdownButtonFormField(
                      value: !snapshot.hasData ? null : snapshot.data,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.teal[800],
                      ),
                      dropdownColor: Colors.teal[800],
                      onChanged: (int selection) =>
                          bloc.changeNumPerformers(selection),
                      items: getPerformerItems(context),
                    );
                  },
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
                Divider(
                  color: Colors.transparent,
                  height: 30.0,
                ),
                Text(
                  'Enter a 4-digit PIN for your room.',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                StreamBuilder(
                  stream: bloc.pin,
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    return PinPut(
                      fieldsCount: 4,
                      controller: bloc.pinText,
                      onChanged: (pin) {
                        print('(host) onChanged: $pin');
                        bloc.validateNewPin(pin);
                      },
                      inputDecoration: InputDecoration(
                        fillColor: Colors.white,
                        errorText: snapshot.hasError ? snapshot.error : null,
                      ),
                    );
                  },
                ),
                Divider(
                  color: Colors.transparent,
                  height: 10.0,
                ),
                Center(
                  child: StreamBuilder(
                    stream: bloc.createRoomValid,
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      return RaisedButton(
                        color: Colors.teal[600],
                        highlightColor: Colors.white,
                        child: Text('Create Room!',
                            style: Theme.of(context).textTheme.bodyText1),
                        onPressed: snapshot.hasData
                            ? () => onCreateRoom(context, bloc, user)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Widget> getPerformerItems(BuildContext context) {
    List<DropdownMenuItem<int>> items = List();

    for (int i = MIN_PERFORMERS; i <= MAX_PERFORMERS; i++) {
      items.add(performerItem(context, i));
    }

    return items;
  }

  void onCreateRoom(BuildContext context, RoomBloc bloc, UserModel user) async {
    print('onCreateRoom!');
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

    bloc.createRoom(user.username);
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SessionScreen(
              user: user,
              roomId: user.username,
              isHost: true,
              role: bloc.currentRole);
        },
      ),
    );
  }

  Widget performerItem(BuildContext context, int value) {
    return DropdownMenuItem(
      value: value,
      child: Text(
        '$value Performers',
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
