import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:jct/src/widgets/fade_text_tile.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/image_model.dart';
import '../resources/image_api_provider.dart';
import 'search_screen.dart';

class Dashboard extends StatefulWidget {
  createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  static const int kNumTiles = 3;

  ImageApiProvider imageProvider;
  Future rndImgFuture;
  int currentIndex = 0;

  // Text files to read
  Future<String> biographyFuture;
  Future<String> descriptionFuture;
  Future<String> howtoFuture;

  initState() {
    super.initState();
    imageProvider = ImageApiProvider();
    rndImgFuture = imageProvider.getPhoto();
    
    // Text from files
    biographyFuture = rootBundle.loadString('assets/biography.txt');
    descriptionFuture = rootBundle.loadString('assets/description.txt');
    howtoFuture = rootBundle.loadString('assets/howto.txt');
  }

  Widget build(context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).unselectedWidgetColor,
        backgroundColor: Theme.of(context).accentColor,
        // onTap: (index) => onNavItemTap(index),
        items: [
          // Dashboard
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          // Appointments
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
          ),
          // Search
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          // My Library
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
          ),
          // Sign in/up or sign out
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0: // Dashboard
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(child: 
                  // TODO: Refactor this mess
                  FutureBuilder(
                    future: Future.wait([
                      rndImgFuture,
                      biographyFuture,
                      descriptionFuture,
                      howtoFuture
                    ]),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final ImageModel image = snapshot.data[0];
                      final String imageUrl = image.urls.full;

                      Widget background =  Container(
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: imageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      );


        final List<String> biography = snapshot.data[1].split('\n');
        final List<String> description = snapshot.data[2].split('\n');
        final List<String> howto = snapshot.data[3].split('\n');

        return Stack(
          children: <Widget>[
            background,
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
              }
            ),
          ],
        );
      }
    ));
            });
            break;
          case 2: // Search
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(child: SearchScreen());
            });
            break;
          default: // Other screens
            return const CupertinoTabView();
        }
        // if (currentIndex != index) {
        //   setState(() => currentIndex = index);
        // }
      },
    );
  }

  // void onNavItemTap(int index) {
  //   if (currentIndex != index) {
  //     setState(() => currentIndex = index);

  //     switch (index) {
  //       case 0: // Dashboard
  //         Navigator.pushNamed(context, '/');
  //         break;
  //       case 1: // Appointments
  //         Navigator.pushNamed(context, '/appointment');
  //         break;
  //       case 2: // Search Music
  //         Navigator.pushNamed(context, '/search');
  //         break;
  //       case 3: // My Library
  //         Navigator.pushNamed(context, '/library');
  //         break;
  //       default: // Sign in/out
  //         // TODO: Implement user auth here
  //         // If (signed in)
  //         // sign out, Navigator.pushNamed(context, '/');
  //         // Else
  //         // Popup asking user to sign in or sign up
  //     }
  //   }
}