import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/screen_type.dart';

/// [TextField]-esque widget reserved at the top of the [AppBar].
///
/// Given a [ScreenType], it will perform an API request to search for
/// compositions, given the context of which screen it belongs to (currently
/// supports [SearchScreen] or [LibraryScreen]).
class SearchField extends StatelessWidget {
  final ScreenType screen;

  SearchField({@required this.screen});

  Widget build(BuildContext context) {
    final searchBloc = SearchProvider.of(context);
    final authBloc = AuthProvider.of(context);

    return Container(
      width: 350,
      height: 48,
      child: Container(
        child: TextFormField(
          controller: searchBloc.searchText,
          cursorColor: Colors.tealAccent[400],
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search Compositions',
            hintStyle: Theme.of(context).textTheme.bodyText1,
            suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => searchBloc.searchText.clear(),
                color: Colors.blue[100]),
          ),
          style: Theme.of(context).textTheme.bodyText1,
          onFieldSubmitted: (text) {
            if (text != '') {
              switch (screen) {
                case ScreenType.SEARCH:
                  searchBloc.search(searchBloc.getFilter(screen), text);
                  break;
                case ScreenType.LIBRARY:
                  searchBloc.search(searchBloc.getFilter(screen), text,
                      composer: authBloc.currentUser.username);
                  break;
                default:
                  break;
              }
              print('Filter $text by ${searchBloc.getFilter(screen)}');
            }
          },
        ),
        margin: EdgeInsets.only(left: 10.0),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );
  }
}
