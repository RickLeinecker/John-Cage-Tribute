import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/screens/composition_info_screen.dart';
import 'package:jct/src/screens/player_screen.dart';

class CompositionTile extends StatelessWidget {
  final ScreenType screen;
  final CompositionModel composition;
  final int index;

  CompositionTile(
      {@required this.composition,
      @required this.screen,
      @required this.index});

  Widget build(context) {
    final AuthBloc authBloc = AuthProvider.of(context);
    final SearchBloc searchBloc = SearchProvider.of(context);
    final int compMinutes = composition.time ~/ 60;
    final int compSeconds = composition.time % 60;
    final bool addMinZero = (compMinutes < 10);
    final bool addSecZero = (compSeconds < 10);

    return Card(
      child: Container(
        color: Theme.of(context).accentColor,
        child: ListTile(
          onTap: () {
            print('${composition.title} was tapped! :)');

            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (context) {
                  return PlayerScreen(composition: composition);
                },
              ),
            );
          },
          // TODO: Line up the metadata closer to the center if the buttons
          // TODO: won't show up.
          title: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Divider(
                    color: Colors.transparent,
                    height: 25.0,
                  ),
                  Text(
                    'Title: ${composition.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Composer: ${composition.composer}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Length: ${addMinZero ? '0' : ''}$compMinutes:${addSecZero ? '0' : ''}$compSeconds',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Positioned(
                bottom: 10.0,
                left: 0,
                right: 0,
                child: optionButtons(context, searchBloc, authBloc.currentUser),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Composition modification can only occur from the Library screen.
  Widget optionButtons(
      BuildContext context, SearchBloc searchBloc, UserModel user) {
    if (screen == ScreenType.LIBRARY) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          editButton(context, searchBloc, user),
          VerticalDivider(
            color: Colors.transparent,
            thickness: 10.0,
          ),
          deleteButton(context, searchBloc, user),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Widget editButton(
      BuildContext context, SearchBloc searchBloc, UserModel user) {
    return SizedBox(
      height: 50.0,
      width: 50.0,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).highlightColor,
        child: IconButton(
          icon: Icon(
            Icons.edit,
            color: Theme.of(context).accentColor,
          ),
          iconSize: 30.0,
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return CompositionInfoScreen(
                  user: user,
                  screen: ScreenType.LIBRARY,
                  composition: composition,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteButton(
      BuildContext context, SearchBloc searchBloc, UserModel user) {
    return SizedBox(
      height: 50.0,
      width: 50.0,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).highlightColor,
        child: IconButton(
          iconSize: 30.0,
          icon: Icon(Icons.delete, color: Theme.of(context).accentColor),
          onPressed: () => onDeleteComposition(context, searchBloc, user),
        ),
      ),
    );
  }

  void onDeleteComposition(
      BuildContext context, SearchBloc bloc, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder(
          stream: bloc.deletingComposition,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            final errorMessage = snapshot.hasError
                ? Text(
                    'There was an issue deleting your composition. Please try again later.\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16.0,
                    ),
                  )
                : SizedBox.shrink();

            return SimpleDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              backgroundColor: Colors.teal,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              children: [
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                Text(
                  'Are you sure you\'d like to delete this composition?\n\nYou won\'t be able to recover it if you do!',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.transparent,
                  height: 30.0,
                ),
                errorMessage,
                deleteProgressOrButtons(context, bloc, user, snapshot),
              ],
            );
          },
        );
      },
    );
  }

  Widget deleteProgressOrButtons(BuildContext context, SearchBloc bloc,
      UserModel user, AsyncSnapshot<bool> snapshot) {
    if (snapshot.hasData && snapshot.data == true) {
      return Container(
        height: 50.0,
        width: 50.0,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RaisedButton(
          color: Colors.teal[600],
          highlightColor: Colors.white,
          child: Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            await bloc.deleteComposition(
                screen, user.id, composition.id, index);
            Navigator.of(context).pop();
          },
        ),
        VerticalDivider(
          color: Colors.transparent,
          width: 10.0,
        ),
        RaisedButton(
          color: Colors.teal[600],
          highlightColor: Colors.white,
          child: Text(
            'No',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
