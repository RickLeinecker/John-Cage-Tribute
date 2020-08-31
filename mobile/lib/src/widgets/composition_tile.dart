import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/screens/composition_info_screen.dart';
import 'package:jct/src/screens/player_screen.dart';

class CompositionTile extends StatelessWidget {
  final CompositionModel composition;

  CompositionTile({@required this.composition});

  Widget build(context) {
    final int compMinutes = composition.time ~/ 60;
    final int compSeconds = composition.time % 60;

    return Card(
      child: Container(
        color: Theme.of(context).accentColor,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) {
                  return PlayerScreen(composition: composition);
                },
              ),
            );
            print('${composition.title} was tapped! :)');
          },
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Title: ${composition.title}'),
              Text('Composer: ${composition.composer}'),
              Text('Length: $compMinutes:$compSeconds'),
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    VerticalDivider(color: Colors.transparent, thickness: 2.0),
                    Text('Edit', style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) {
                      return CompositionInfoScreen(
                        screen: ScreenType.LIBRARY,
                        composition: composition,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
