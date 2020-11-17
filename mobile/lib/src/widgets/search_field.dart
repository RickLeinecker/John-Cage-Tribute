import 'package:flutter/material.dart';

import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/user_model.dart';

/// [TextField]-esque widget reserved at the top of the [AppBar].
///
/// Given a [ScreenType], it will perform an API request to search for
/// compositions, given the context of which screen it belongs to (currently
/// supports [SearchScreen] or [LibraryScreen]).
class SearchField extends StatelessWidget {
  final UserModel user;
  final ScreenType screen;

  SearchField({this.user, @required this.screen});

  Widget build(BuildContext context) {
    final searchBloc = SearchProvider.of(context);

    return Container(
      width: 180,
      height: 43,
      child: Container(
        child: TextFormField(
          controller: searchBloc.searchText,
          cursorColor: Colors.cyanAccent[400],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 10.0, top: 6.0),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.blue[100]),
            suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => searchBloc.searchText.clear(),
                color: Colors.white),
          ),
          style: Theme.of(context).textTheme.bodyText1,
          onFieldSubmitted: (text) {
            final query = text.trim();

            if (query != '') {
              searchBloc.search(
                user: user,
                filter: searchBloc.getFilter(screen),
                query: query,
                screen: screen,
              );

              print('Filter $text by ${searchBloc.getFilter(screen)}');
            }
          },
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );
  }
}
