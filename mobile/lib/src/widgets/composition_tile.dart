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

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      tileColor: !composition.isProcessing()
          ? Colors.lightBlueAccent[700]
          : Colors.grey,
      enabled: !composition.isProcessing(),
      title: Text(
        composition.title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20.0),
      ),
      subtitle: Text(
        composition.composer,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 16.0),
      ),
      onTap: composition.isProcessing() ? null : () => goToPlayer(context),
      trailing: trailingItems(context, searchBloc, authBloc.currentUser),
    );
  }

  void goToPlayer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) {
          return PlayerScreen(screen: screen, composition: composition);
        },
      ),
    );
  }

  // Presents a composition's duration if it has finished processing. In
  // addition, it presents edit/delete buttons when searched via the library.
  Widget trailingItems(BuildContext context, SearchBloc bloc, UserModel user) {
    if (composition.isProcessing()) {
      return Wrap(
        spacing: 12,
        children: <Widget>[
          Text(
            '(Processing...)',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Icon(Icons.hourglass_bottom),
        ],
      );
    }

    final int compMinutes =
        composition.isProcessing() ? 0 : composition.time ~/ 60;
    final int compSeconds =
        composition.isProcessing() ? 0 : (composition.time % 60).floor();

    final bool addMinZero = (compMinutes < 10);
    final bool addSecZero = (compSeconds < 10);

    final duration =
        Text('${addMinZero ? '0' : ''}$compMinutes:${addSecZero ? '0' : ''}'
            '$compSeconds');

    switch (screen) {
      case ScreenType.SEARCH:
        return duration;
      case ScreenType.LIBRARY:
        return Wrap(
          spacing: 12,
          children: <Widget>[
            editButton(context, bloc, user),
            deleteButton(context, bloc, user),
          ],
        );
      // Unsupported screen type.
      default:
        return Icon(Icons.error);
    }
  }

  Widget editButton(BuildContext context, SearchBloc bloc, UserModel user) {
    return IconButton(
      iconSize: 30.0,
      icon: Icon(Icons.edit),
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
    );
  }

  Widget deleteButton(BuildContext context, SearchBloc bloc, UserModel user) {
    return IconButton(
      iconSize: 30.0,
      icon: Icon(Icons.delete),
      onPressed: () => onDeleteComposition(context, bloc, user),
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
                      color: Colors.red[900],
                      fontSize: 16.0,
                    ),
                  )
                : SizedBox.shrink();

            return SimpleDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              backgroundColor: Colors.cyan,
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
                deletingOrButtons(context, bloc, user, snapshot),
              ],
            );
          },
        );
      },
    );
  }

  Widget deletingOrButtons(BuildContext context, SearchBloc bloc,
      UserModel user, AsyncSnapshot<bool> snapshot) {
    if (snapshot.hasData && snapshot.data == true) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RaisedButton(
          color: Colors.cyan[100],
          highlightColor: Colors.white,
          textColor: Colors.cyan[900],
          child: Text('Yes'),
          onPressed: () async {
            await bloc.deleteComposition(user.id, composition.id, index);
            Navigator.of(context).pop();
          },
        ),
        VerticalDivider(
          color: Colors.transparent,
          width: 35.0,
        ),
        RaisedButton(
          color: Colors.cyan[100],
          highlightColor: Colors.white,
          textColor: Colors.cyan[900],
          child: Text('No'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
