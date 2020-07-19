import 'package:flutter/material.dart';
import 'search_bloc.dart';

class SearchProvider extends InheritedWidget {
  final SearchBloc bloc = SearchBloc();

  SearchProvider({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static SearchBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchProvider>().bloc;
  }
}
