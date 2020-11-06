import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/widgets/composition_tile.dart';
import 'package:jct/src/widgets/dropdown_filters.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/search_field.dart';

class SearchScreen extends StatelessWidget {
  Widget build(context) {
    SearchBloc bloc = SearchProvider.of(context);
    return nonGuestScaffold(context, bloc);
  }

  Widget nonGuestScaffold(BuildContext context, SearchBloc bloc) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          title: SearchField(screen: ScreenType.SEARCH),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Filter By: ',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  width: 150,
                  child: DropdownFilters(screen: ScreenType.SEARCH),
                ),
              ],
            ),
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
                    else if (!searchingSnapshot.hasData ||
                        (compSnapshot.data == null && !compSnapshot.hasError)) {
                      return GreetingMessage(
                        greeting: GreetingType.SEARCH,
                        message: 'Musical masterpieces will display here!',
                      );
                    }

                    // A search has been completed.
                    else {
                      if (compSnapshot.hasError) {
                        return GreetingMessage(
                          greeting: GreetingType.ERROR,
                          message: 'Awww, shucks!\n${compSnapshot.error}',
                        );
                      } else {
                        if (compSnapshot.data.length == 0) {
                          return GreetingMessage(
                            greeting: GreetingType.NORESULTS,
                            message:
                                'Whoops! No search meeting your criteria was found...',
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
        snapshot.data.elementAt(index).printComposition(); // TODO: Remove

        return CompositionTile(
          composition: snapshot.data.elementAt(index),
          screen: ScreenType.SEARCH,
          index: index,
        );
      },
    );
  }
}
