import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/bloc.dart';
import 'package:jct/src/constants/greeting_type.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/room_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/widgets/greeting_message.dart';
import 'package:jct/src/widgets/host_button.dart';
import 'package:jct/src/widgets/room_tile.dart';
import 'package:jct/src/widgets/scroll_to_refresh.dart';

class RoomScreen extends StatelessWidget {
  final UserModel user;

  RoomScreen({@required this.user});

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return WillPopScope(
      onWillPop: () async {
        bloc.disconnectSocket();
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Rooms',
          ),
          backgroundColor: Theme.of(context).accentColor,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: StreamBuilder(
          stream: bloc.rooms,
          builder: (context, AsyncSnapshot<Map<String, RoomModel>> snapshot) {
            if (!snapshot.hasData) {
              return SizedBox.expand(
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.data.length == 0) {
              return Stack(
                children: [
                  ScrollToRefresh(),
                  RefreshIndicator(
                    onRefresh: () async => bloc.updateRooms(),
                    child: ListView(children: []),
                  ),
                  Center(
                    child: GreetingMessage(
                      greeting: GreetingType.ROOM,
                      message:
                          'No aspiring musicians found here!${user == GUEST_USER ? '' : '\n Would you like to be one?'}',
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 60.0,
                      ),
                      child: HostButton(user: user),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                ScrollToRefresh(),
                RefreshIndicator(
                  onRefresh: () async => bloc.updateRooms(),
                  child: ListView(children: []),
                  displacement: 20.0,
                ),
                Container(
                  height: 500,
                  padding: EdgeInsets.only(top: 100.0),
                  child: GridView.builder(
                    itemCount: snapshot.data.length,
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final String key = snapshot.data.keys.elementAt(index);

                      return RoomTile(user: user, room: snapshot.data[key]);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 60.0,
                    ),
                    child: HostButton(user: user),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
