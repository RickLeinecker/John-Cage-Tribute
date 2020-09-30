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
    final bool addZero = compSeconds == 0;

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
          title: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Divider(
                    color: Colors.transparent,
                    height: 40.0,
                  ),
                  Text(
                    'Title: ${composition.title}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Composer: ${composition.composer}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Length: $compMinutes:$compSeconds${addZero ? '0' : ''}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Positioned(
                bottom: 5.0,
                left: 0,
                right: 0,
                child: editButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget editButton(BuildContext context) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.edit, color: Theme.of(context).accentColor),
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
    );
  }
}
