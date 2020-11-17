import 'package:flutter/material.dart';

import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/composition_tile.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/search_app_bar.dart';

class LibraryScreen extends StatelessWidget {
  final UserModel user;

  LibraryScreen({@required this.user});

  Widget build(context) {
    final SearchBloc bloc = SearchProvider.of(context);

    return WillPopScope(
      onWillPop: () async {
        bloc.clearSearchResults();
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: SearchAppBar(user: user, screen: ScreenType.LIBRARY),
        ),
        body: Stack(
          children: [
            SizedBox.expand(
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            Center(
              child: StreamBuilder(
                stream: bloc.querySearch,
                builder: (context, AsyncSnapshot<bool> searchingSnapshot) {
                  return StreamBuilder(
                    stream: bloc.searchCompList,
                    builder: (context,
                        AsyncSnapshot<List<CompositionModel>> compSnapshot) {
                      // A search is currently being performed.
                      if (searchingSnapshot.hasData &&
                          searchingSnapshot.data == true) {
                        return loadingCircle(context);
                      }

                      // No searches have been performed yet.
                      if (!searchingSnapshot.hasData ||
                          (compSnapshot.data == null &&
                              !compSnapshot.hasError)) {
                        return GreetingMessage(
                          greeting: GreetingType.LIBRARY,
                          message:
                              'Your glorious collection will show up here!',
                        );
                      }

                      // A search has been completed.
                      else {
                        if (compSnapshot.hasError) {
                          return GreetingMessage(
                            greeting: GreetingType.ERROR,
                            message: 'Oh, no!\n${compSnapshot.error}',
                          );
                        } else {
                          if (compSnapshot.data.isEmpty) {
                            return GreetingMessage(
                              greeting: GreetingType.NORESULTS,
                              message:
                                  'Darn. Looks like you have no compositions '
                                  'that meet that criteria.',
                            );
                          }

                          return compositionsDisplay(compSnapshot);
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadingCircle(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget compositionsDisplay(AsyncSnapshot<List<CompositionModel>> snapshot) {
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return CompositionTile(
          composition: snapshot.data.elementAt(index),
          screen: ScreenType.LIBRARY,
          index: index,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 5.0,
        );
      },
    );
  }
}
