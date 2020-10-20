import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:transparent_image/transparent_image.dart';
// import '../models/unsplash/unsplash_image_model.dart';
// import '../resources/image_api_provider.dart';

import 'package:jct/src/blocs/auth/bloc.dart';
import 'package:jct/src/widgets/fade_text_tile.dart';
import 'package:jct/src/screens/library_screen.dart';
import 'package:jct/src/screens/auth_screen.dart';
import 'package:jct/src/screens/pre_room_screen.dart';
import 'package:jct/src/screens/search_screen.dart';

class Dashboard extends StatefulWidget {
  createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  static const int kNumTiles = 3;

  // ImageApiProvider imageProvider;
  // Future rndImgFuture;
  int currentIndex = 0;

  // Retrieve text files from assets folder
  Future<String> biographyFuture;
  Future<String> descriptionFuture;
  Future<String> howtoFuture;

  initState() {
    super.initState();
    // imageProvider = ImageApiProvider();
    // rndImgFuture = imageProvider.getPhoto();

    // Text assets
    biographyFuture = rootBundle.loadString('assets/biography.txt');
    descriptionFuture = rootBundle.loadString('assets/description.txt');
    howtoFuture = rootBundle.loadString('assets/howto.txt');
  }

  Widget build(context) {
    final AuthBloc bloc = AuthProvider.of(context);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).unselectedWidgetColor,
        backgroundColor: Theme.of(context).accentColor,
        onTap: (index) {},
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.assignment)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.library_music)),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app)),
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
                  child: PreRoomScreen(user: bloc.user),
                );
              },
            );
          case 2: // Search
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(child: SearchScreen());
              },
            );
          case 3: // Library
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: LibraryScreen(),
                );
              },
            );
            break;
          case 4: // Login/Signup
            return CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: AuthScreen(),
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
        [/*rndImgFuture,*/ biographyFuture, descriptionFuture, howtoFuture],
      ),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return defaultBackground(
            containerChild: Center(
                child:
                    CircularProgressIndicator(backgroundColor: Colors.white)),
          );
        }

        // final UnsplashImageModel image = snapshot.data[0];
        // final String imageUrl = image.urls.full;

        // Widget background = Container(
        //   child: FadeInImage.memoryNetwork(
        //     placeholder: kTransparentImage,
        //     image: imageUrl,
        //     fit: BoxFit.cover,
        //     height: double.infinity,
        //     width: double.infinity,
        //   ),
        // );

        final List<String> biography = snapshot.data[0].split('\n');
        final List<String> description = snapshot.data[1].split('\n');
        final List<String> howto = snapshot.data[2].split('\n');

        return Stack(
          children: <Widget>[
            defaultBackground(containerChild: null),
            // background,
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
