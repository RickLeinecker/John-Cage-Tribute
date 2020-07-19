import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/blocs/search/bloc.dart';
import '../../src/constants/screen_type.dart';
import '../../src/models/composition_model.dart';
import '../../src/widgets/composition_tile.dart';
import '../../src/widgets/no_results.dart';
import '../../src/widgets/filter_buttons.dart';
import '../../src/widgets/search_field.dart';

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
            preferredSize: Size.fromHeight(50.0),
            child: FilterButtons(screen: ScreenType.SEARCH),
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
              stream: bloc.searchCompList,
              builder:
                  (context, AsyncSnapshot<List<CompositionModel>> snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.queue_music,
                          size: 120.0, color: Theme.of(context).accentColor),
                      Text('Musical masterpieces will display here!',
                          textAlign: TextAlign.center),
                    ],
                  );
                } else {
                  if (snapshot.data.length == 0) {
                    return NoResults();
                  }

                  return GridView.builder(
                    itemCount: snapshot.data.length,
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      return CompositionTile(
                        composition: snapshot.data.elementAt(index),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
