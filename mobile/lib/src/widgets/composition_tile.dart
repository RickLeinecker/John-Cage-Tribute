import 'package:flutter/material.dart';
import '../models/composition_model.dart';

class CompositionTile extends StatelessWidget {
  final CompositionModel composition;

  CompositionTile({@required this.composition});

  Widget build(context) {
    final int compMinutes = composition.secs ~/ 60;
    final int compSeconds = composition.secs % 60;

    return Card(
      child: Container(
        color: Theme.of(context).accentColor,
        child: ListTile(
          onTap: () => print('${composition.title} was tapped! :)'),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Title: ${composition.title}'),
              Text('Composer: ${composition.composer}'),
              Text('Length: $compMinutes:$compSeconds'),
            ],
          ),
        ),
      ),
    );
  }
}
