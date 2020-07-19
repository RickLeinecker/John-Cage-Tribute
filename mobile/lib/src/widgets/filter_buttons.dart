import 'package:flutter/material.dart';
import '../../src/constants/filter_option.dart';
import '../../src/constants/screen_type.dart';
import '../../src/blocs/search/bloc.dart';

class FilterButtons extends StatelessWidget {
  final ScreenType screen;

  FilterButtons({@required this.screen});

  Widget build(BuildContext context) {
    final bloc = SearchProvider.of(context);

    return StreamBuilder(
      stream:
          screen == ScreenType.SEARCH ? bloc.filterSearch : bloc.filterLibrary,
      builder: (context, AsyncSnapshot<FilterOption> snapshot) {
        return Wrap(
          direction: Axis.horizontal,
          spacing: 10.0,
          children: [
            RaisedButton(
              color: bloc.getFilter(screen) == FilterOption.TAGS
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor,
              child: Text('Tags'),
              textColor: Colors.white,
              onPressed: () => bloc.changeFilter(screen, FilterOption.TAGS),
            ),
            allowComposedByButton(context, bloc, screen),
            RaisedButton(
              color: bloc.getFilter(screen) == FilterOption.PERFORMED_BY
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor,
              child: Text('Performed By'),
              textColor: Colors.white,
              onPressed: () =>
                  bloc.changeFilter(screen, FilterOption.PERFORMED_BY),
            )
          ],
        );
      },
    );
  }

  Widget allowComposedByButton(
      BuildContext context, SearchBloc bloc, ScreenType screen) {
    Widget composedByButton = RaisedButton(
      color: bloc.getFilter(screen) == FilterOption.COMPOSED_BY
          ? Theme.of(context).highlightColor
          : Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text('Composed By'),
      onPressed: () => bloc.changeFilter(screen, FilterOption.COMPOSED_BY),
    );

    switch (screen) {
      case ScreenType.SEARCH:
        return composedByButton;

      case ScreenType.LIBRARY:
        return Visibility(
          visible: false,
          child: composedByButton,
        );

      default:
        return Container();
    }
  }
}
