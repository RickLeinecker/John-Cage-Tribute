import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/models/member_model.dart';
import 'package:jct/src/widgets/action_button.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/seconds_timer.dart';
import 'package:jct/src/widgets/start_session_button.dart';

import 'package:native_widgets/native_widgets.dart';

class SessionScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MemberModel member;
  final String roomId;
  final String pin;

  SessionScreen(
      {Key key, @required this.member, @required this.roomId, this.pin})
      : super(key: key);

  State<StatefulWidget> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int secondsElapsed = 0;
  Timer oneSecTimer;

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: bloc.sessionHasBegun,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final atMaxPerformerCapacity = snapshot.hasData;

        return WillPopScope(
          onWillPop: () async {
            if (!widget.member.isHost &&
                (widget.member.role == Role.LISTENER ||
                    !atMaxPerformerCapacity ||
                    snapshot.data == false)) {
              bloc.leaveRoom(widget.roomId, widget.member.isHost);
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
            key: widget._scaffoldKey,
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
                  if (!widget.member.isHost &&
                      (widget.member.role == Role.LISTENER ||
                          !atMaxPerformerCapacity ||
                          snapshot.data == false)) {
                    bloc.leaveRoom(widget.roomId, widget.member.isHost);
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
                    onTap: () =>
                        widget._scaffoldKey.currentState.openEndDrawer(),
                    child: Icon(
                      Icons.supervisor_account,
                      size: 26.0,
                    ),
                  ),
                ),
              ],
            ),
            endDrawer: membersDrawer(context, bloc),
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
                          if (!widget.member.isHost) {
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

                        String pinInfo = '';

                        if (widget.member.isHost) {
                          if (widget.pin != null) {
                            pinInfo = 'Room PIN: ${widget.pin}';
                          } else {
                            pinInfo = 'This room is PIN-free!';
                          }
                        }

                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  Divider(
                                    height: 10.0,
                                    color: Colors.transparent,
                                  ),
                                  Text(
                                    pinInfo,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Divider(
                                    height: 70.0,
                                    color: Colors.transparent,
                                  ),
                                  SecondsTimer(),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: ActionButton(
                                  roomId: widget.roomId,
                                  role: widget.member.role),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 60.0,
                                ),
                                child: widget.member.isHost
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

  Widget membersDrawer(BuildContext context, RoomBloc bloc) {
    return Drawer(
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
                child: CircularProgressIndicator(backgroundColor: Colors.white),
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
              'Are you sure you\'d like to leave the room? \n\n${(widget.member.isHost ? 'Your room will close and its members will have to leave.' : 'You\'re performing in the middle of a session!')}',
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
                    if (widget.member.isHost) {
                      bloc.watch?.stop();
                      bloc.timer?.cancel();

                      print('Host has left their room.');
                    }

                    bloc.leaveRoom(widget.roomId, widget.member.isHost);
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
    switch (widget.member.role) {
      case Role.LISTENER:
        return 'Thanks for tuning in, '
            '${widget.member.isGuest ? 'guest' : widget.member.username}!';

      case Role.PERFORMER:
        if (widget.member.isGuest) {
          return 'Thanks for pitching in, guest!\nYour audio will live on!';
        }

        return 'Awesome job, ${widget.member.username}! You\'ll be credited for'
            ' this composition!';

      default:
        return '(Role not yet supported) Session complete.';
    }
  }

  Widget memberList(BuildContext context, Map<String, MemberModel> members) {
    final performerWidgets = List<Widget>();
    performerWidgets
        .add(Text('Performers', style: Theme.of(context).textTheme.headline6));

    final listenerWidgets = List<Widget>();
    listenerWidgets
        .add(Text('Listeners', style: Theme.of(context).textTheme.headline6));

    for (String socketId in members.keys) {
      final member = members[socketId];

      if (member.role == Role.PERFORMER) {
        performerWidgets
            .add(Text(member.isGuest ? '(Guest)' : member.username));
        performerWidgets.add(Divider(color: Colors.transparent, height: 10.0));
      } else {
        listenerWidgets.add(Text(member.isGuest ? '(Guest)' : member.username));
        listenerWidgets.add(Divider(color: Colors.transparent, height: 10.0));
      }
    }

    // Also counts the "Performer" or "Listener" text widget.
    if (performerWidgets.length == 1) {
      performerWidgets.add(Text('None yet!'));
    }

    if (listenerWidgets.length == 1) {
      listenerWidgets.add(Text('None yet!'));
    }

    performerWidgets.insert(
        0, Divider(color: Colors.transparent, height: 50.0));

    return Stack(
      alignment: FractionalOffset(0.5, 0.1),
      children: [
        Stack(
          alignment: FractionalOffset(0.5, 0.1),
          children: [
            Icon(
              Icons.mic,
              color: Theme.of(context).accentColor,
              size: 120.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: performerWidgets,
            ),
          ],
        ),
        Stack(
          alignment: FractionalOffset(0.5, 0.57),
          children: [
            Icon(
              Icons.headset,
              color: Theme.of(context).accentColor,
              size: 120.0,
            ),
            Column(
              children: listenerWidgets,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ),
      ],
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

          if (widget.member.role == Role.PERFORMER) {
            return Text(
              'Put on a good show, ${widget.member.isGuest ? 'guest' : widget.member.username}!',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            );
          }
          // Otherwise, your role is a Listener.
          else {
            return Text(
              'Hope you enjoy this performance, ${widget.member.isGuest ? 'guest' : widget.member.username}!',
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
