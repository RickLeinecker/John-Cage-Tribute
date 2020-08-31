import 'package:flutter/material.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/composition_tile.dart';
import 'package:jct/src/widgets/filter_buttons.dart';
import 'package:jct/src/widgets/loading_user.dart';
import 'package:jct/src/widgets/not_registered.dart';
import 'package:jct/src/widgets/search_field.dart';
import 'package:jct/src/widgets/no_results.dart';

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
              stream: bloc.libraryCompList,
              builder:
                  (context, AsyncSnapshot<List<CompositionModel>> snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.music_video,
                          size: 120.0, color: Theme.of(context).accentColor),
                      Text('Your glorious collection will show up here!',
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
