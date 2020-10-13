import 'package:flutter/material.dart';

import 'package:jct/src/constants/greeting_type.dart';

class GreetingMessage extends StatelessWidget {
  final GreetingType greeting;
  final String message;

  const GreetingMessage({
    @required this.greeting,
    @required this.message,
  });

  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        getIconType(context),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Icon getIconType(BuildContext context) {
    IconData iconData;

    switch (greeting) {
      case GreetingType.ROOM:
        iconData = Icons.speaker_notes_off;
        break;

      case GreetingType.SEARCH:
        iconData = Icons.queue_music;
        break;

      case GreetingType.LIBRARY:
        iconData = Icons.music_video;
        break;

      case GreetingType.ERROR:
        iconData = Icons.sentiment_very_dissatisfied;
        break;

      case GreetingType.SUCCESS:
        iconData = Icons.sentiment_very_satisfied;
        break;

      case GreetingType.NORESULTS:
        iconData = Icons.help_outline;
        break;

      default:
        iconData = Icons.warning;
        break;
    }

    return Icon(
      iconData,
      size: 120.0,
      color: Theme.of(context).accentColor,
    );
  }
}
