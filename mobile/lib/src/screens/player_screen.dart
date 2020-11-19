import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:flutter/material.dart';

import 'package:jct/src/blocs/search/bloc.dart';
import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/models/composition_model.dart';

class PlayerScreen extends StatefulWidget {
  final CompositionModel composition;

  PlayerScreen({@required this.composition});

  createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  AssetsAudioPlayer player;
  bool loadSuccess;
  bool initFailed;
  String url;

  void initState() {
    super.initState();

    player = AssetsAudioPlayer();
    initFailed = false;
    loadSuccess = false;
    url = '$baseUrl/$compUrl/view/${widget.composition.id}';
    _init();
  }

  Widget build(context) {
    SearchBloc bloc = SearchProvider.of(context);

    return WillPopScope(
      onWillPop: () async {
        player.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
          title: Text(
            'Return to Main Screen',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: playerBody(bloc),
      ),
    );
  }

  void _init() async {
    try {
      final audio = Audio.network(
        url,
        metas: Metas(
          title: widget.composition.title,
          artist: widget.composition.composer,
        ),
      );

      await player.open(audio, autoStart: false, showNotification: true);
      setState(() => loadSuccess = true);
    } catch (e) {
      print('Uh oh, there was an issue initailizing the player!\nError: $e');
      setState(() => initFailed = true);
    }
  }

  Widget playerBody(SearchBloc bloc) {
    if (initFailed) {
      bloc.clearSearchResults();

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 120.0, color: Theme.of(context).accentColor),
            Text(
              'Our servers were unable to\nretrieve audio data. Please try again later!',
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: ListView(
        children: [
          Divider(
            height: 20.0,
            color: Colors.transparent,
          ),
          Text(
            widget.composition.title,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Text(
            'by ${widget.composition.composer}',
            textAlign: TextAlign.center,
          ),
          Divider(
            height: 20.0,
            color: Colors.transparent,
          ),
          loadOrAudioWidgets(),
          Divider(
            height: 25.0,
            color: Colors.transparent,
          ),
          Text(
            'Description',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Divider(
            height: 10.0,
            color: Colors.transparent,
          ),
          Text(
            widget.composition.description,
            textAlign: TextAlign.center,
          ),
          Divider(
            height: 20.0,
            color: Colors.transparent,
          ),
          Text(
            'Performers',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Divider(
            height: 10.0,
            color: Colors.transparent,
          ),
          Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              performersOrGuests(),
            ],
          ),
        ],
      ),
    );
  }

  Widget seekBar() {
    return StreamBuilder<Duration>(
      stream: player.currentPosition,
      builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

        final int currentSeconds = snapshot.data.inSeconds;

        return Slider(
          min: 0.0,
          max: widget.composition.time,
          value: currentSeconds.toDouble(),
          onChanged: (double value) {
            setState(() {
              seekToSecond(value.toInt());
              value = value;
            });
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
        );
      },
    );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    player.seek(newDuration);
  }

  Widget loadOrAudioWidgets() {
    return StreamBuilder(
      stream: player.isPlaying,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData || !loadSuccess) {
          return Align(
            heightFactor: 2.2,
            widthFactor: 2.2,
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );
        }

        final isPlaying = snapshot.data;

        return Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: () async {
                  await player.playOrPause();
                },
              ),
              seekBar(),
              PlayerBuilder.currentPosition(
                player: player,
                builder: (context, duration) {
                  final curSecs = duration.inSeconds;
                  final cmpSecs = widget.composition.time.floor();

                  bool addMinZero = (curSecs ~/ 60) < 10;
                  bool addSecZero = (curSecs % 60) < 10;

                  final curTime =
                      '${addMinZero ? '0' : ''}${curSecs ~/ 60}:${addSecZero ? '0' : ''}${curSecs % 60}';

                  addMinZero = (cmpSecs ~/ 60) < 10;
                  addSecZero = (cmpSecs % 60) < 10;

                  final cmpTime =
                      '${addMinZero ? '0' : ''}${cmpSecs ~/ 60}:${addSecZero ? '0' : ''}${cmpSecs % 60}';

                  return Text('$curTime / $cmpTime');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget performersOrGuests() {
    if (widget.composition.performers.isEmpty) {
      return Text(
        '(A bundle of guests! 😄)',
        textAlign: TextAlign.center,
      );
    }

    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.composition.performers.length,
        itemBuilder: (context, index) {
          return Text(
            widget.composition.performers.elementAt(index),
            textAlign: TextAlign.center,
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.transparent,
            height: 5.0,
          );
        },
      ),
    );
  }

  void dispose() {
    super.dispose();
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
              widget.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));
            }
            _dragValue = null;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
