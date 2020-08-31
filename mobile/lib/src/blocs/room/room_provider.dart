import 'package:flutter/material.dart';

import 'package:jct/src/blocs/room/room_bloc.dart';

class RoomProvider extends InheritedWidget {
  final RoomBloc bloc = RoomBloc();

  RoomProvider({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static RoomBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RoomProvider>().bloc;
  }
}
