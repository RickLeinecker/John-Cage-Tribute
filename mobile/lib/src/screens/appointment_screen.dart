import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jct/src/widgets/scroll_to_refresh.dart';
import '../blocs/room/bloc.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../widgets/host_button.dart';
import '../widgets/loading_user.dart';
import '../widgets/no_appointments.dart';
import '../widgets/room_tile.dart';
import '../widgets/scroll_to_refresh.dart';

class AppointmentScreen extends StatelessWidget {
  final Stream<UserModel> user;

  AppointmentScreen({@required this.user});

  Widget build(context) {
    final RoomBloc bloc = RoomProvider.of(context);

    return StreamBuilder(
      stream: user,
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        if (!snapshot.hasData) {
          return LoadingUser();
        }

        final UserModel userModel = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Appointments',
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
                      child: NoAppointments(user: userModel),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 60.0,
                        ),
                        child: HostButton(user: userModel),
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
                          crossAxisCount: 2),
                      itemBuilder: (BuildContext context, int index) {
                        final String key = snapshot.data.keys.elementAt(index);
                        return RoomTile(
                            joiningUser: userModel.username,
                            room: snapshot.data[key]);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 60.0,
                      ),
                      child: HostButton(user: userModel),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
