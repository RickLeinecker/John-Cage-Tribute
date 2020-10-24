import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/models/member_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/start_session_button.dart';

class SessionScreen extends StatelessWidget {
  final UserModel user;
  final String roomId;
  final bool isHost;
  final Role role;

  SessionScreen({
    @required this.user,
    @required this.roomId,
    @required this.isHost,
    @required this.role,
  });

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return WillPopScope(
      onWillPop: () {
        print('Are you sure you wanna exit?');

        return showDialog(
          context: context,
          builder: (context) {
            return confirmLeaveRoom(context, bloc);
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Close Room and Return'),
          backgroundColor: Theme.of(context).accentColor,
        ),
        body: Stack(
          children: [
            SizedBox.expand(
              child: Container(
                color: Theme.of(context).primaryColor,
                child: StreamBuilder(
                  stream: bloc.members,
                  builder: (context,
                      AsyncSnapshot<Map<String, MemberModel>> snapshot) {
                    if (snapshot.hasError) {
                      return roomErrorWidget(context, snapshot.error);
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      );

                      // The session has successfully ended, no members remain
                      // in the room.
                    } else if (snapshot.data.length == 0) {
                      if (!isHost) {
                        return GreetingMessage(
                          greeting: GreetingType.SUCCESS,
                          message: successMessage(),
                        );
                      }

                      return Column(
                        children: [
                          Text(
                            'Please wait while we save your composition...',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        ],
                      );
                    }

                    return memberListColumn(context, snapshot.data);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget confirmLeaveRoom(BuildContext context, RoomBloc bloc) {
    return AlertDialog(
      backgroundColor: Colors.teal,
      content: Container(
        height: 300,
        width: 200,
        color: Colors.teal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Are you sure you\'d like to leave the room? \n\nIf you\'re the host, the room will close and its members will have to leave.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20.0)),
            Divider(
              color: Colors.transparent,
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Colors.teal[600],
                  highlightColor: Colors.white,
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    bloc.leaveRoom(roomId);
                    Navigator.of(context).pop(true);
                  },
                ),
                VerticalDivider(
                  color: Colors.transparent,
                  width: 10.0,
                ),
                RaisedButton(
                  color: Colors.teal[600],
                  highlightColor: Colors.white,
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String successMessage() {
    switch (role) {
      case Role.LISTENER:
        return 'Thanks for tuning in, ${user == GUEST_USER ? 'guest' : user.username}!';

      case Role.PERFORMER:
        if (user == GUEST_USER) {
          return 'Thanks for pitching in, guest!\nYour audio will live on!';
        }

        return 'Awesome job, ${user.username}! You\'ll be credited for this composition!';

      default:
        return '(Role not yet supported) Session complete.';
    }
  }

  Widget memberListColumn(
      BuildContext context, Map<String, MemberModel> members) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
          memberListIcons(context, members),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: (isHost ? StartSessionButton() : Container()),
            ),
          ),
          Divider(
            color: Colors.transparent,
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Widget roomErrorWidget(BuildContext context, String errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sentiment_very_dissatisfied,
          size: 50.0,
        ),
        Divider(
          color: Colors.transparent,
          height: 10.0,
        ),
        Text(
          'Uh oh. An error has occurred...',
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        Divider(
          color: Colors.transparent,
          height: 10.0,
        ),
        Text(
          errorText,
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget memberListIcons(
      BuildContext context, Map<String, MemberModel> members) {
    final List<Widget> memberIconList = List();

    for (String key in members.keys) {
      memberIconList.add(memberIcon(context, members[key]));
    }

    return Column(
      children: memberIconList,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget memberIcon(BuildContext context, MemberModel member) {
    return Column(
      children: [
        Icon(member.role == Role.PERFORMER ? Icons.mic : Icons.headset),
        Text(
          member.isGuest ? '(GUEST)' : member.username,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}
