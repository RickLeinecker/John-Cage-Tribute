import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/pin_metadata.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/session_screen.dart';
import 'package:jct/src/widgets/role_buttons.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

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
      ),
    );
  }

  void onHostButtonPressed(BuildContext context, RoomBloc bloc) async {
    await showDialog(
      context: context,
      builder: (context) {
        String enteredPin = '';
        bool pinEnabled = false;

        return AlertDialog(
          backgroundColor: Colors.teal,
          insetPadding: EdgeInsets.only(
            left: 30.0,
            right: 30.0,
            top: 90.0,
            bottom: 90.0,
          ),
          contentPadding: EdgeInsets.zero,
          title: Text(
            'About Your Room',
            textAlign: TextAlign.center,
          ),
          titleTextStyle: Theme.of(context).textTheme.headline6,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final typedEntirePIN = (enteredPin.length == PIN_LENGTH);

              return SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      Divider(
                        color: Colors.transparent,
                        height: 15.0,
                      ),
                      SwitchListTile(
                        activeColor: Colors.greenAccent[700],
                        title: Text(
                          'Protect with PIN?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        secondary: pinEnabled
                            ? Icon(Icons.lock)
                            : Icon(Icons.lock_open_sharp),
                        value: pinEnabled,
                        onChanged: (value) =>
                            setState(() => pinEnabled = value),
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 15.0,
                      ),
                      Text(
                        'Enter its $PIN_LENGTH-digit PIN.',
                        style: pinEnabled
                            ? Theme.of(context).textTheme.bodyText1
                            : Theme.of(context).textTheme.subtitle2,
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
                          enabled: pinEnabled,
                          keyboardType: TextInputType.number,
                          length: PIN_LENGTH,
                          onChanged: (pin) => setState(() => enteredPin = pin),
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
                      Divider(
                        color: Colors.transparent,
                        height: 10.0,
                      ),
                      Center(
                        child: RaisedButton(
                          color: Theme.of(context).textTheme.bodyText2.color,
                          textColor: Colors.teal[900],
                          highlightColor: Colors.white,
                          child: Text('Create'),
                          onPressed: !pinEnabled || typedEntirePIN
                              ? () => onCreateRoom(
                                  context, bloc, user, enteredPin, pinEnabled)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void onCreateRoom(BuildContext context, RoomBloc bloc, UserModel user,
      String enteredPin, bool pinEnabled) async {
    print('Creating room!');
    if (bloc.currentRole == Role.PERFORMER) {
      print('Can confirm you\'re a performer!');
      if (!await Permission.microphone.request().isGranted) {
        print('Hmmm, you didn\'t grant the mic permission last time.');
        if (await Permission.microphone.isPermanentlyDenied) {
          print('Permanently denied? Please accept this time! :(');
          openAppSettings();

          if (!await Permission.microphone.isGranted) {
            print('Ah, thanks for revoking the permanent denial there! :)');
            return;
          }
        } else {
          print('[host_button] Mic permission denied.');
          return;
        }
      }
    }

    bloc.createRoom(user.username, pinEnabled, enteredPin);

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SessionScreen(
            user: user,
            roomId: user.username,
            isHost: true,
            role: bloc.currentRole,
          );
        },
      ),
    );
  }
}
