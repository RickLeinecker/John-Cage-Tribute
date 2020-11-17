import 'package:flutter/material.dart';

import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/filter_option.dart';
import 'package:jct/src/constants/screen_type.dart';

class DropdownFilters extends StatelessWidget {
  final ScreenType screen;

  DropdownFilters({@required this.screen});

  Widget build(context) {
    SearchBloc bloc = SearchProvider.of(context);

    return SizedBox(
      width: 105,
      height: 45.0,
      child: StreamBuilder(
        stream: bloc.filterSearch,
        builder: (context, AsyncSnapshot<FilterOption> snapshot) {
          return Container(
            color: Theme.of(context).accentColor,
            child: DropdownButtonFormField(
              isExpanded: true,
              value: !snapshot.hasData ? null : snapshot.data,
              dropdownColor: Theme.of(context).primaryColor,
              onChanged: (FilterOption filter) =>
                  bloc.changeFilterSearch(filter),
              items: getFilterMenuItems(context),
            ),
          );
        },
      ),
    );
  }

  List<Widget> getFilterMenuItems(BuildContext context) {
    List<DropdownMenuItem<FilterOption>> items = List();

    for (FilterOption filter in FilterOption.values) {
      // Search via composer when searching one's own compositions is redundant.
      if (filter == FilterOption.COMPOSED_BY && screen == ScreenType.LIBRARY) {
        continue;
      }

      items.add(filterItem(context, filter));
    }

    return items;
  }

  Widget filterItem(BuildContext context, FilterOption filter) {
    String text;

    switch (filter) {
      case FilterOption.TITLE:
        text = 'Title';
        break;
      case FilterOption.TAGS:
        text = 'Tags';
        break;
      case FilterOption.COMPOSED_BY:
        text = 'Composer';
        break;
      case FilterOption.PERFORMED_BY:
        text = 'Performer';
        break;
      default:
        text = 'Unsupported Filter Option';
        break;
    }

    return DropdownMenuItem(
      value: filter,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
