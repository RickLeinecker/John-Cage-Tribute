import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:flutter/material.dart';

import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/constants/guest_user.dart';
import 'package:jct/src/models/composition_model.dart';
import 'package:jct/src/widgets/no_appointments.dart';

class PlayerScreen extends StatefulWidget {
  final CompositionModel composition;

  PlayerScreen({@required this.composition});

  createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool initFailed;
  bool _play;
  String url;
  // AssetsAudioPlayer player;

  void initState() {
    super.initState();
    setState(() => initFailed = false);
    setState(() => _play = false);
    // player = new AssetsAudioPlayer();
    final jct = 'https://johncagetribute.org';
    url = jct + compositionUrl + '/${widget.composition.url}';
    print('url: $url');
    // initPlayer(url);
  }

  // void initPlayer(String url) async {
  //   try {
  //     await player.open(
  //       Audio.network(url),
  //     );
  //   } catch (error) {
  //     print('Error initializing player: $error');
  //     setState(() => initFailed = true);
  //   }
  // }

  Widget build(context) {
    if (initFailed) {
      // TODO: Return failed screen kinda like recording screen.
      return NoAppointments(user: GUEST_USER);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.composition.title,
            style: Theme.of(context).textTheme.bodyText1),
      ),
      body: Center(
        child: AudioWidget.network(
          url: url,
          play: _play,
          child: RaisedButton(
              child: Text(
                _play ? "pause" : "play",
              ),
              onPressed: () {
                setState(() {
                  _play = !_play;
                });

                // player.playOrPause();
              }),
          onReadyToPlay: (duration) {
            //onReadyToPlay
          },
          onPositionChanged: (current, duration) {
            //onReadyToPlay
          },
        ),
      ),
    );
  }
}
