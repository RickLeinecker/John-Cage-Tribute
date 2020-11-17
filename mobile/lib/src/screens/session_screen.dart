import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/models/member_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/action_button.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/start_session_button.dart';

import 'package:native_widgets/native_widgets.dart';

// TODO: Show time elapsed, change its color over time (i.e. gray if < 2 min, red if > 90% MAX_TIME, yellow if > 70% MAX_TIME, white if > 2 min)
class SessionScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserModel user;
  final String roomId;
  final bool isHost;
  final Role role;

  SessionScreen({
    Key key,
    @required this.user,
    @required this.roomId,
    @required this.isHost,
    @required this.role,
  }) : super(key: key);

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: bloc.sessionHasBegun,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final atMaxPerformerCapacity = snapshot.hasData;

        return WillPopScope(
          onWillPop: () async {
            if (!isHost &&
                (role == Role.LISTENER ||
                    !atMaxPerformerCapacity ||
                    snapshot.data == false)) {
              bloc.leaveRoom(roomId, isHost);
              return true;
            }

            print('Are you sure you wanna exit?');
            return showDialog(
              context: context,
              builder: (context) {
                return confirmLeaveRoom(context, bloc);
              },
            );
          },
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              title: Text('Close Room and Return'),
              backgroundColor: Theme.of(context).accentColor,
              leading: NativeIconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 26.0,
                ),
                iosIcon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 26.0,
                ),
                onPressed: () async {
                  if (!isHost &&
                      (role == Role.LISTENER ||
                          !atMaxPerformerCapacity ||
                          snapshot.data == false)) {
                    bloc.leaveRoom(roomId, isHost);
                    Navigator.pop(context);
                  } else {
                    print('Are you sure you wanna exit?');
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return confirmLeaveRoom(context, bloc);
                      },
                    );
                  }
                },
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () => _scaffoldKey.currentState.openEndDrawer(),
                    child: Icon(
                      Icons.supervisor_account,
                      size: 26.0,
                    ),
                  ),
                ),
              ],
            ),
            endDrawer: Drawer(
              child: Container(
                color: Theme.of(context).primaryColor,
                child: StreamBuilder(
                  stream: bloc.members,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, MemberModel>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'No member data available for this room. :(',
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      );
                    } else if (snapshot.data.isEmpty) {
                      return Center(
                        child: Text(
                          'Session complete! :)',
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return memberList(context, snapshot.data);
                  },
                ),
              ),
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

                          // The session has successfully ended.
                          // No members should remain in the room.
                        } else if (snapshot.data.isEmpty) {
                          if (!isHost) {
                            return GreetingMessage(
                              greeting: GreetingType.SUCCESS,
                              message: successMessage(),
                            );
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                              Divider(
                                color: Colors.transparent,
                                height: 10.0,
                              ),
                              Text(
                                'Please wait while we save your composition...',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          );
                        }

                        return Stack(
                          children: [
                            // TODO: Maybe add a StreamBuilder here that checks whether a user joined or left, y'know, to fill this empty space!!!
                            Align(
                              alignment: Alignment.center,
                              child: ActionButton(roomId: roomId, role: role),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 60.0,
                                ),
                                child: isHost
                                    ? StartSessionButton()
                                    : sessionStartNotifier(context, bloc),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget confirmLeaveRoom(BuildContext context, RoomBloc bloc) {
    return AlertDialog(
      backgroundColor: Colors.cyan[600],
      content: Container(
        height: 250,
        width: 200,
        color: Colors.cyan[600],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you\'d like to leave the room? \n\n${(isHost ? 'Your room will close and its members will have to leave.' : 'You\'re performing in the middle of a session!')}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Divider(
              color: Colors.transparent,
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Theme.of(context).textTheme.bodyText2.color,
                  textColor: Colors.cyan[900],
                  highlightColor: Colors.white,
                  child: Text('Yes'),
                  onPressed: () {
                    if (isHost) {
                      bloc.watch?.stop();
                      bloc.timer?.cancel();

                      print('Host has left their room.');
                    }

                    bloc.leaveRoom(roomId, isHost);
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop();
                  },
                ),
                VerticalDivider(
                  color: Colors.transparent,
                  width: 35.0,
                ),
                RaisedButton(
                  color: Theme.of(context).textTheme.bodyText2.color,
                  textColor: Colors.cyan[900],
                  highlightColor: Colors.white,
                  child: Text('No'),
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

  Widget memberList(BuildContext context, Map<String, MemberModel> members) {
    List<String> performers = List();
    List<String> listeners = List();

    for (String socketId in members.keys) {
      final member = members[socketId];

      if (member.role == Role.PERFORMER) {
        performers.add(member.isGuest ? '(GUEST)' : member.username);
      } else {
        listeners.add(member.isGuest ? '(GUEST)' : member.username);
      }
    }

    final perfHeadingIdx = 0;
    final listHeadingIdx = performers.length + 1;

    // The "Performers" and "Listeners" headings are part of the ListView.
    return ListView.separated(
      itemCount: performers.length + listeners.length + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == perfHeadingIdx) {
          return Text(
            'Performers',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          );
        } else if (index <= performers.length) {
          return Text(
            performers.elementAt(index - 1),
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          );
        } else if (index == listHeadingIdx) {
          return Text(
            'Listeners',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          );
        } else {
          return Text(
            listeners.elementAt(index - performers.length - 2),
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        if (index == listHeadingIdx - 1) {
          return Divider(
            color: Colors.transparent,
            height: 80.0,
          );
        } else {
          return Divider(
            color: Colors.transparent,
            height: 20.0,
          );
        }
      },
    );
  }

  // A text widget notifying a non-host of the current status of the room.
  Widget sessionStartNotifier(BuildContext context, RoomBloc bloc) {
    return StreamBuilder(
      stream: bloc.sessionHasBegun,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Text(
            'Awaiting remaining performers...',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          );
        } else {
          if (snapshot.data == false) {
            return Text(
              'Waiting on the host to start the session!',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            );
          }

          if (role == Role.PERFORMER) {
            return Text(
              'Put on a good show, ${user == GUEST_USER ? 'guest' : user.username}!',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            );
          }
          // Otherwise, your role is a Listener.
          else {
            return Text(
              'Hope you enjoy this performance, ${user == GUEST_USER ? 'guest' : user.username}!',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            );
          }
        }
      },
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
}
