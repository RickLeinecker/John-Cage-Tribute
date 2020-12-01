import 'dart:async';

import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/composition_durations.dart';

class SecondsTimer extends StatefulWidget {
  State<StatefulWidget> createState() => _SecondsTimerState();
}

class _SecondsTimerState extends State<SecondsTimer> {
  int secondsElapsed = 0;
  Timer oneSecTimer;

  Widget build(context) {
    RoomBloc bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: bloc.sessionHasBegun,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData || snapshot.data == false) {
          oneSecTimer?.cancel();
          return Text('--:-- / --:--', style: TextStyle(color: Colors.grey));
        }

        if (oneSecTimer == null && snapshot.data == true) {
          beginCountingSeconds();
        }

        if (secondsElapsed >= COMPOSITION_MAX_TIME) {
          oneSecTimer?.cancel();
          return Text('Time\'s up!',
              style: Theme.of(context).textTheme.bodyText1);
        }

        if (secondsElapsed < COMPOSITION_MIN_TIME) {
          return Text(_timeFormat(secondsElapsed, COMPOSITION_MIN_TIME),
              style: TextStyle(color: Colors.black));
        } else if (secondsElapsed >= COMPOSITION_ONE_MINUTE_LEFT) {
          return Text(_timeFormat(secondsElapsed, COMPOSITION_MAX_TIME),
              style: TextStyle(color: Colors.red));
        } else if (secondsElapsed >= COMPOSITION_TWO_MINUTES_LEFT) {
          return Text(_timeFormat(secondsElapsed, COMPOSITION_MAX_TIME),
              style: TextStyle(color: Colors.orange));
        } else {
          return Text(_timeFormat(secondsElapsed, COMPOSITION_MAX_TIME),
              style: TextStyle(color: Colors.green));
        }
      },
    );
  }

  String _timeFormat(int curSec, int maxSec) {
    String formatted = '';

    formatted += '${curSec ~/ 60}';

    formatted += ':';

    int leftoverSeconds = curSec % 60;
    if (leftoverSeconds < 10) {
      formatted += '0' + '$leftoverSeconds';
    } else {
      formatted += '$leftoverSeconds';
    }

    formatted += ' / ';

    formatted += '${maxSec ~/ 60}';

    formatted += ':';

    leftoverSeconds = maxSec % 60;
    if (leftoverSeconds < 10) {
      formatted += '0' + '$leftoverSeconds';
    } else {
      formatted += '$leftoverSeconds';
    }

    return formatted;
  }

  void beginCountingSeconds() {
    const oneSec = const Duration(seconds: 1);

    oneSecTimer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(() => secondsElapsed = secondsElapsed + 1),
    );
  }

  void dispose() {
    oneSecTimer?.cancel();
    super.dispose();
  }
}
