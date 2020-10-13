import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/composition_tile.dart';
import 'package:jct/src/widgets/filter_buttons.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/loading_user.dart';
import 'package:jct/src/widgets/not_registered.dart';
import 'package:jct/src/widgets/search_field.dart';

class LibraryScreen extends StatelessWidget {
  Widget build(context) {
    final SearchBloc searchBloc = SearchProvider.of(context);
    final AuthBloc authBloc = AuthProvider.of(context);

    return StreamBuilder(
      stream: authBloc.user,
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) {
          return LoadingUser();
        }

        if (snapshot.data == GUEST_USER) {
          return NotRegistered();
        }

        return nonGuestScaffold(context, searchBloc);
      },
    );
  }

  Widget nonGuestScaffold(BuildContext context, SearchBloc bloc) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          title: SearchField(screen: ScreenType.LIBRARY),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: FilterButtons(screen: ScreenType.LIBRARY),
          ),
        ),
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
              stream: bloc.queryLibrary,
              builder: (context, AsyncSnapshot<bool> searchingSnapshot) {
                return StreamBuilder(
                  stream: bloc.libraryCompList,
                  builder: (context,
                      AsyncSnapshot<List<CompositionModel>> compSnapshot) {
                    // No searches have been performed yet.
                    if (!searchingSnapshot.hasData) {
                      return GreetingMessage(
                        greeting: GreetingType.LIBRARY,
                        message: 'Your glorious collection will show up here!',
                      );
                    }

                    // A search is currently being performed.
                    else if (searchingSnapshot.data == true) {
                      return loadingCircle(context);
                    }

                    // A search has been completed.
                    else {
                      if (compSnapshot.hasError) {
                        return GreetingMessage(
                          greeting: GreetingType.ERROR,
                          message: 'Oh, no!\nerrorMessage${compSnapshot.error}',
                        );
                      } else {
                        if (compSnapshot.data.length == 0) {
                          return GreetingMessage(
                            greeting: GreetingType.NORESULTS,
                            message:
                                'Darn. Looks like you have no compositions that meet that criteria.',
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
    return GridView.builder(
      itemCount: snapshot.data.length,
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return CompositionTile(
          composition: snapshot.data.elementAt(index),
          screen: ScreenType.LIBRARY,
          index: index,
        );
      },
    );
  }
}
