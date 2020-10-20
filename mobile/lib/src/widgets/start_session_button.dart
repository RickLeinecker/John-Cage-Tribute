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
  Timer _timer;
  Stopwatch _watch;
  bool sessionStarted;
  BehaviorSubject<bool> _toggleSession;

  Stream<bool> get toggleSession => _toggleSession.stream;
  Function(bool) get changeToggleSession => _toggleSession.sink.add;

  void initState() {
    super.initState();
    sessionStarted = false;
    _toggleSession = BehaviorSubject();
    changeToggleSession(true);
  }

  Widget build(context) {
    AuthBloc authBloc = AuthProvider.of(context);
    RoomBloc roomBloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: roomBloc.sessionReady,
      builder: (BuildContext context, AsyncSnapshot<bool> allPerfsSnap) {
        return StreamBuilder(
          stream: toggleSession,
          builder: (context, AsyncSnapshot<bool> timeSnap) {
            return RaisedButton(
              onPressed: (!timeSnap.hasData || !allPerfsSnap.hasData)
                  ? null
                  : () => onToggleSession(authBloc, roomBloc),
              color: Colors.teal,
              textColor: Colors.white,
              child: Text(
                (!sessionStarted ? 'Go!' : 'Stop!'),
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      },
    );
  }

  void onToggleSession(AuthBloc authBloc, RoomBloc roomBloc) async {
    if (!sessionStarted) {
      roomBloc.startSession();

      _timer = Timer(Duration(seconds: MAX_COMPOSITION_TIME),
          () => finishSession(authBloc, roomBloc));

      _watch = Stopwatch()..start();

      // Disables the session button from being clicked until MIN_COMPOSITION
      // time passes.
      _toggleSession.sink.addError(
          'Composition must be at least ${MIN_COMPOSITION_TIME ~/ 60} min.');

      changeToggleSession(await Future.delayed(
          Duration(seconds: MIN_COMPOSITION_TIME), () => true));
    } else {
      finishSession(authBloc, roomBloc);
    }

    setState(() => sessionStarted = !sessionStarted);
  }

  void finishSession(AuthBloc authBloc, RoomBloc roomBloc) async {
    final runtimeInSeconds = _watch.elapsed.inSeconds;

    _watch.stop();
    _timer.cancel();
    final compositionId =
        await roomBloc.endSession(authBloc.currentUser, runtimeInSeconds);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return CompositionInfoScreen(
              user: authBloc.currentUser,
              screen: ScreenType.SESSION,
              composition: CompositionModel.emptyModel(id: compositionId));
        },
      ),
    );
  }

  void dispose() {
    _toggleSession.close();
    super.dispose();
  }
}
