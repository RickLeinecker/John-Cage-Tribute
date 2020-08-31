import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:jct/src/widgets/start_session_button.dart';
import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/models/member_model.dart';

class SessionScreen extends StatelessWidget {
  final String user;
  final String roomId;
  final bool isHost;

  SessionScreen(
      {@required this.user, @required this.roomId, @required this.isHost});

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return WillPopScope(
      onWillPop: () {
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
                    }

                    return Center(
                      child: Container(
                        margin: EdgeInsets.only(left: 10.0),
                        height: 400,
                        width: 300,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            memberListIcons(snapshot.data),
                            VerticalDivider(
                              width: 20.0,
                              color: Colors.transparent,
                            ),
                            (isHost ? StartSessionButton() : Container()),
                          ],
                        ),
                      ),
                    );
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
      backgroundColor: Colors.red[900],
      content: Container(
        height: 300,
        width: 200,
        color: Colors.red[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Are you sure you\'d like to leave the room?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Colors.red[300],
                  child: Text('Yes', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    bloc.leaveRoom(roomId);
                    Navigator.of(context).pop(true);
                  },
                ),
                RaisedButton(
                  color: Colors.red[300],
                  child: Text('No', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            )
          ],
        ),
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

  Widget recordButton(BuildContext context) {
    return RaisedButton(
      child: Container(
        child: Icon(
          Icons.mic,
          size: 100.0,
        ),
        margin: EdgeInsets.all(10.0),
      ),
      onPressed: () {},
      shape: CircleBorder(),
      highlightColor: Colors.white,
      color: Theme.of(context).accentColor,
    );
  }

  Widget memberListIcons(Map<String, MemberModel> members) {
    final List<Widget> memberIconList = List();

    for (String key in members.keys) {
      memberIconList.add(memberIcon(members[key]));
    }

    return Column(
      children: memberIconList,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget memberIcon(MemberModel member) {
    return Column(
      children: [
        Icon(member.role == Role.PERFORMER ? Icons.mic : Icons.headset),
        Text(member.isGuest ? '(GUEST)' : member.username)
      ],
    );
  }
}
