import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/filter_option.dart';
import 'package:jct/src/widgets/fade_text_tile.dart';
import 'package:jct/src/screens/account_screen.dart';
import 'package:jct/src/screens/pre_room_screen.dart';
import 'package:jct/src/screens/search_screen.dart';

class Dashboard extends StatefulWidget {
  createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  static const int kNumTiles = 3;
  int currentIndex = 0;

  // Retrieve text files from assets folder
  Future<String> biographyFuture;
  Future<String> descriptionFuture;
  Future<String> howtoFuture;

  initState() {
    super.initState();

    // Text assets
    biographyFuture = rootBundle.loadString('assets/biography.txt');
    descriptionFuture = rootBundle.loadString('assets/description.txt');
    howtoFuture = rootBundle.loadString('assets/howto.txt');
  }

  Widget build(context) {
    final AuthBloc authBloc = AuthProvider.of(context);
    final SearchBloc searchBloc = SearchProvider.of(context);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).unselectedWidgetColor,
        backgroundColor: Theme.of(context).accentColor,
        onTap: (index) {
          if (index == 2) {
            searchBloc.clearSearchResults();
          } else if (index == 3) {
            searchBloc.changeFilterSearch(FilterOption.TITLE);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.assignment)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0: // Dashboard
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: dashboardFutureBuilder(),
                );
              },
            );
            break;
          case 1: // Session Rooms
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: PreRoomScreen(user: authBloc.user),
                );
              },
            );
          case 2: // Search
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(child: SearchScreen());
              },
            );
            break;
          case 3: // Login/Signup
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: AccountScreen(),
                );
              },
            );
            break;
          default: // Error screen
            return const CupertinoTabView();
        }
      },
    );
  }

  Widget dashboardFutureBuilder() {
    return FutureBuilder(
      future: Future.wait(
        [biographyFuture, descriptionFuture, howtoFuture],
      ),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return defaultBackground(
            containerChild: Center(
                child:
                    CircularProgressIndicator(backgroundColor: Colors.white)),
          );
        }

        final List<String> biography = snapshot.data[0].split('\n');
        final List<String> description = snapshot.data[1].split('\n');
        final List<String> howto = snapshot.data[2].split('\n');

        return Stack(
          children: <Widget>[
            defaultBackground(containerChild: null),
            ListView.separated(
              itemCount: kNumTiles,
              itemBuilder: (context, int index) {
                Widget homeTextTile;

                switch (index) {
                  case 0:
                    homeTextTile = FadeTextTile(
                      title: biography[0],
                      body: biography[1],
                    );
                    break;
                  case 1:
                    homeTextTile = FadeTextTile(
                      title: description[0],
                      body: description[1],
                    );
                    break;
                  case 2:
                    homeTextTile = FadeTextTile(
                      title: howto[0],
                      body: howto[1],
                    );
                    break;
                  default:
                    homeTextTile = FadeTextTile(
                      title: 'Title',
                      body: 'Body',
                    );
                }

                return Column(
                  children: [
                    Divider(height: 200.0, color: Colors.transparent),
                    homeTextTile,
                  ],
                );
              },
              padding: EdgeInsets.all(20.0),
              separatorBuilder: (context, index) {
                return Divider(height: 300.0, color: Colors.transparent);
              },
            ),
          ],
        );
      },
    );
  }

  Widget defaultBackground({containerChild}) {
    return SizedBox.expand(
      child: Container(
          color: Theme.of(context).primaryColor, child: containerChild),
    );
  }
}
