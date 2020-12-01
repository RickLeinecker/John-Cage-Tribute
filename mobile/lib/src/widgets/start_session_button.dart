import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:rxdart/rxdart.dart';
import '../blocs/room/bloc.dart';
import '../../src/constants/composition_durations.dart';
import '../../src/constants/screen_type.dart';
import '../../src/screens/composition_info_screen.dart';

class StartSessionButton extends StatefulWidget {
  _StartSessionButtonState createState() => _StartSessionButtonState();
}

class _StartSessionButtonState extends State<StartSessionButton> {
  BehaviorSubject<bool> _toggleSession;
  Timer enforceMinTimeForComp;

  Stream<bool> get toggleSession => _toggleSession.stream;
  Function(bool) get changeToggleSession => _toggleSession.sink.add;

  void initState() {
    super.initState();
    _toggleSession = BehaviorSubject<bool>();
    changeToggleSession(true);
  }

  Widget build(context) {
    final authBloc = AuthProvider.of(context);
    final roomBloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: roomBloc.sessionHasBegun,
      builder: (BuildContext context, AsyncSnapshot<bool> startedSnap) {
        return StreamBuilder(
          stream: toggleSession,
          builder: (context, AsyncSnapshot<bool> timeSnap) {
            final sessionHasBegun =
                startedSnap.hasData && startedSnap.data == true;
            final canStartOrEnd = timeSnap.hasData && timeSnap.data == true;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                timeSnap.hasData
                    ? RaisedButton(
                        onPressed: (!startedSnap.hasData ||
                                (sessionHasBegun && !canStartOrEnd))
                            ? null
                            : () => onToggleSession(
                                authBloc, roomBloc, sessionHasBegun),
                        color: Theme.of(context).textTheme.bodyText2.color,
                        textColor: Theme.of(context).primaryColor,
                        child: Text(
                          (!startedSnap.hasData || !startedSnap.data == true)
                              ? 'Begin'
                              : 'End',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : CircularProgressIndicator(backgroundColor: Colors.white),
              ],
            );
          },
        );
      },
    );
  }

  void onToggleSession(
      AuthBloc authBloc, RoomBloc roomBloc, bool sessionHasBegun) async {
    if (!sessionHasBegun) {
      roomBloc.startSession();

      roomBloc.timer = Timer(Duration(seconds: COMPOSITION_MAX_TIME),
          () => finishSession(authBloc, roomBloc));

      roomBloc.watch = Stopwatch()..start();

      _toggleSession.sink.add(false);

      enforceMinTimeForComp =
          Timer(Duration(seconds: COMPOSITION_MIN_TIME), () {
        if (!_toggleSession.isClosed) {
          _toggleSession.sink.add(true);
        }
      });
    } else {
      finishSession(authBloc, roomBloc);
    }
  }

  void finishSession(AuthBloc authBloc, RoomBloc roomBloc) async {
    _toggleSession.sink.add(null);

    roomBloc.watch?.stop();
    roomBloc.timer?.cancel();
    enforceMinTimeForComp?.cancel();
    final compositionId = await roomBloc.endSession(authBloc.currentUser);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return CompositionInfoScreen(
            user: authBloc.currentUser,
            screen: ScreenType.SESSION,
            composition: CompositionModel.empty(id: compositionId),
          );
        },
      ),
    );
  }

  void dispose() {
    _toggleSession.close();
    enforceMinTimeForComp?.cancel();
    super.dispose();
  }
}
