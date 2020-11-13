import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/role.dart';

class ActionButton extends StatelessWidget {
  final String roomId;
  final Role role;

  ActionButton({@required this.roomId, @required this.role});

  Widget build(context) {
    final bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: bloc.isActive,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // Session not yet started.
        if (!snapshot.hasData) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Icon(
                      Icons.watch_later,
                      color: Colors.grey,
                      size: 100.0,
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.transparent,
                height: 10.0,
              ),
              Text(
                'Awaiting session initiation...',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          );
        }

        bool active = snapshot.data;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Material(
                color: active ? Colors.blue[700] : Colors.blue,
                shadowColor: Colors.blue[900],
                child: InkWell(
                  splashColor: active ? Colors.blue[700] : Colors.blue,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: getActionIcon(context, active),
                  ),
                  onTap: () => bloc.muteOrDeafen(roomId, role, active),
                ),
              ),
            ),
            Divider(
              color: Colors.transparent,
              height: 10.0,
            ),
            getActionText(context, active),
          ],
        );
      },
    );
  }

  Widget getActionIcon(BuildContext context, bool active) {
    if (role == Role.PERFORMER) {
      return Icon(
        active ? Icons.mic : Icons.mic_off,
        size: 100.0,
      );
    } else {
      return Icon(
        active ? Icons.headset : Icons.headset_off,
        size: 100.0,
      );
    }
  }

  Widget getActionText(BuildContext context, bool active) {
    if (role == Role.PERFORMER) {
      return Text(
        (active ? 'Click to Mute' : 'Click to Unmute'),
        style: Theme.of(context).textTheme.bodyText1,
      );
    } else {
      return Text(
        (active ? 'Click to Deafen' : 'Click to Undeafen'),
        style: Theme.of(context).textTheme.bodyText1,
      );
    }
  }
}
