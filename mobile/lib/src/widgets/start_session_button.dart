import 'package:flutter/material.dart';
import '../blocs/room/bloc.dart';

class StartSessionButton extends StatefulWidget {
  final String roomId;

  StartSessionButton({@required this.roomId});

  _StartSessionButtonState createState() => _StartSessionButtonState();
}

class _StartSessionButtonState extends State<StartSessionButton> {
  bool sessionStarted;

  void initState() {
    super.initState();
    sessionStarted = false;
  }

  Widget build(BuildContext context) {
    RoomBloc bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: bloc.sessionReady,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return RaisedButton(
          onPressed: !snapshot.hasData
              ? null
              : () {
                  if (!sessionStarted) {
                    bloc.startSession();
                  } else {
                    bloc.endSession(widget.roomId);
                  }
                  setState(() => sessionStarted = !sessionStarted);
                },
          color: Colors.teal,
          textColor: Colors.white,
          child: Text(
            (!sessionStarted ? 'Go!' : 'Stop!'),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
