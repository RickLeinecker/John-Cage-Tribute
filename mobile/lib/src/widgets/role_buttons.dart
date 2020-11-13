import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/role.dart';

class RoleButtons extends StatelessWidget {
  Widget build(BuildContext context) {
    final bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: bloc.role,
      builder: (context, AsyncSnapshot<Role> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(
            backgroundColor: Colors.white,
          );
        }

        final selectedRole = snapshot.data;

        return ButtonBar(
          alignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            RaisedButton.icon(
              textColor: Colors.teal[900],
              elevation: selectedRole == Role.LISTENER ? 5.0 : 16.0,
              color: selectedRole == Role.LISTENER
                  ? Colors.teal[300]
                  : Colors.teal[100],
              highlightColor: Colors.teal,
              icon: Icon(Icons.headset),
              label: Text(
                'Listener',
              ),
              onPressed: () => bloc.changeRole(Role.LISTENER),
            ),
            RaisedButton.icon(
                textColor: Colors.teal[900],
                elevation: selectedRole == Role.PERFORMER ? 5.0 : 16.0,
                color: selectedRole == Role.PERFORMER
                    ? Colors.teal[300]
                    : Colors.teal[100],
                highlightColor: Colors.teal,
                icon: Icon(Icons.mic),
                label: Text(
                  'Performer',
                ),
                onPressed: () => bloc.changeRole(Role.PERFORMER)),
          ],
        );
      },
    );
  }
}
