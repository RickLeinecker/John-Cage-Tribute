import 'package:flutter/material.dart';

import 'package:jct/src/constants/filter_option.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/dropdown_filters.dart';
import 'package:jct/src/widgets/search_field.dart';

enum Action { NONE, SEARCH, FILTER }

class SearchAppBar extends StatefulWidget {
  final UserModel user;
  final ScreenType screen;

  SearchAppBar({@required this.screen, this.user});

  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  Action action;

  void initState() {
    super.initState();
    this.action = Action.NONE;
  }

  Widget build(context) {
    return AppBar(
      automaticallyImplyLeading: widget.screen == ScreenType.LIBRARY,
      backgroundColor: Theme.of(context).accentColor,
      centerTitle: widget.screen != ScreenType.LIBRARY,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          titleWidget(context, action),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          splashRadius: 20.0,
          onPressed: action != Action.SEARCH
              ? () => setState(() => action = Action.SEARCH)
              : null,
        ),
        IconButton(
          icon: Icon(Icons.filter_alt),
          splashRadius: 20.0,
          onPressed: action != Action.FILTER
              ? () => setState(() => action = Action.FILTER)
              : null,
        ),
      ],
    );
  }

  String filterIndicator(FilterOption filter) {
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
        text = 'No Filter.';
    }

    return text;
  }

  Widget titleWidget(BuildContext context, Action action) {
    switch (action) {
      case Action.SEARCH:
        if (widget.screen == ScreenType.LIBRARY) {
          return SearchField(user: widget.user, screen: widget.screen);
        }

        return SearchField(screen: widget.screen);
      case Action.FILTER:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Filter by:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            VerticalDivider(
              color: Colors.transparent,
              width: 10.0,
            ),
            DropdownFilters(screen: widget.screen),
          ],
        );
      default:
        return Text(
          'Your Compositions',
          style: TextStyle(color: Colors.white),
        );
    }
  }
}
