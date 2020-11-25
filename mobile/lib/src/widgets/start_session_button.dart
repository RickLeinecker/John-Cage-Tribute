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
            final sessionStarted = startedSnap.data == true;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: timeSnap.hasError,
                  child: Text(
                    timeSnap.error ?? '',
                    textAlign: TextAlign.center,
                  ),
                ),
                Visibility(
                  visible: timeSnap.hasError,
                  child: Divider(
                    color: Colors.transparent,
                    height: 10.0,
                  ),
                ),
                RaisedButton(
                  onPressed: (!timeSnap.hasData || !startedSnap.hasData)
                      ? null
                      : () =>
                          onToggleSession(authBloc, roomBloc, sessionStarted),
                  color: Theme.of(context).textTheme.bodyText2.color,
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    (!sessionStarted ? 'Begin' : 'End'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void onToggleSession(
      AuthBloc authBloc, RoomBloc roomBloc, bool sessionStarted) async {
    if (!sessionStarted) {
      roomBloc.startSession();

      roomBloc.timer = Timer(Duration(seconds: MAX_COMPOSITION_TIME),
          () => finishSession(authBloc, roomBloc));

      roomBloc.watch = Stopwatch()..start();

      // Disables the session button from being clicked until MIN_COMPOSITION
      // time passes.
      _toggleSession.sink.addError(
          'Composition must be at least ${MIN_COMPOSITION_TIME ~/ 60} min ${MIN_COMPOSITION_TIME / 60 == 0 ? '' : ' and ${MIN_COMPOSITION_TIME % 60} sec'} long.');

      changeToggleSession(await Future.delayed(
          Duration(seconds: MIN_COMPOSITION_TIME), () => true));
    } else {
      finishSession(authBloc, roomBloc);
    }

    setState(() => sessionStarted = !sessionStarted);
  }

  void finishSession(AuthBloc authBloc, RoomBloc roomBloc) async {
    _toggleSession.sink.add(null);

    roomBloc.watch.stop();
    roomBloc.timer.cancel();
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
    super.dispose();
  }
}
