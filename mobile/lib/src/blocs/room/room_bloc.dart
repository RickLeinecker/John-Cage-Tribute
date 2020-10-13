import 'dart:async';

import 'package:audio_buffer_player/audio_buffer_player.dart';

import 'package:audio_streamer/audio_streamer.dart';

import 'package:flutter/material.dart';

import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/models/member_model.dart';
import 'package:jct/src/models/room_model.dart';
import 'package:jct/src/models/status_model.dart';
import 'package:jct/src/resources/composition_api_repository.dart';

import 'package:rxdart/rxdart.dart';

import 'package:socket_io_client/socket_io_client.dart';

class RoomBloc {
  // Room Screen
  final pinText = TextEditingController();
  final _rooms = BehaviorSubject<Map<String, RoomModel>>();
  final _pin = BehaviorSubject<String>();
  final _numPerformers = BehaviorSubject<int>();
  final _role = BehaviorSubject<Role>();
  final _createRoomValid = BehaviorSubject<bool>();
  final _joinRoomValid = BehaviorSubject<bool>();

  // Session Screen
  final _members = BehaviorSubject<Map<String, MemberModel>>();
  final _sessionReady = BehaviorSubject<bool>();
  final _compositionRepo = CompositionApiRepository();

  String currentRoom;
  Socket socket;
  Role currentRole;
  Map<String, dynamic> composition;
  AudioStreamer _audioStreamer;
  AudioBufferPlayer _bufferPlayer;
  bool _isRecording;

  Function(int) get changeNumPerformers => _numPerformers.sink.add;
  Function(Role) get changeRole => _role.sink.add;
  Function(String) get changePinValid => _pin.sink.add;

  Stream<Map<String, RoomModel>> get rooms => _rooms.stream;
  Stream<Map<String, MemberModel>> get members => _members.stream;
  Stream<int> get numPerformers => _numPerformers.stream;
  Stream<Role> get role => _role.stream;
  Stream<String> get pin => _pin.stream;
  Stream<bool> get sessionReady => _sessionReady.stream;

  Stream<bool> get createRoomValid => Rx.combineLatest3(
      numPerformers, role, pin, (slctPerf, slctRole, pin) => true);

  Stream<bool> get joinRoomValid =>
      Rx.combineLatest2(role, pin, (slctRole, pin) => true);

  RoomBloc() {
    _isRecording = false;
    initSocket();
  }

  /// Handles socket initialization at the creation of a RoomBloc.
  void initSocket() {
    socket = io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    composition = {};

    onSocketConnections();
  }

  void connectSocket() {
    socket.connect();
  }

  void disconnectSocket() {
    socket.disconnect();
  }

  /// Encompasses all socket.on connections required for the
  /// app's socket.io behavior.
  void onSocketConnections() {
    // Updates list of available rooms in Room Screen
    socket.on('updaterooms', (data) {
      print('Updated rooms!');
      final Map<String, RoomModel> roomMap = Map();

      for (String key in data.keys) {
        roomMap[key] = RoomModel.fromJson(data[key]);
      }

      _rooms.sink.add(roomMap);
    });

    // Updates list of members shown on a particular room
    socket.on('updatemembers', (data) {
      print('Received updatemembers from server!');
      final Map<String, MemberModel> membersMap = Map();

      for (String key in data.keys) {
        membersMap[key] = MemberModel.fromJson(data[key]);
      }

      if (data.length >= 1 /*_numPerformers.value*/) {
        _sessionReady.sink.add(true);
      } else {
        _sessionReady.addError('');
      }

      _members.sink.add(membersMap);
    });

    // Compares the entered PIN to the room's PIN on the server, returning null
    // if the two are not equal.
    socket.on('verifypin', (data) {
      print('data: $data');
      if (data != null) {
        _pin.add(data);
      } else {
        _pin.addError(data);
      }
    });

    // Socket event for when an audio recording session finally begins.
    // We capture the list of performers in our composition at this stage.
    socket.on('audiostart', (data) {
      _isRecording = true;
      print('(audiostart socket) _isRecording: $_isRecording');

      final performers = List<String>();

      for (String user in _members.value.keys) {
        final MemberModel member = _members.value[user];

        if (member.role == Role.PERFORMER) {
          performers.add(member.username);
        }
      }

      // Save this here for establishing this composition's list of performer
      // info (or composition metadata).
      composition['performers'] = performers;

      if (currentRole == Role.LISTENER) {
        _bufferPlayer.init();
      } else {
        _audioStreamer.start(onAudio);
      }
    });

    // Receives mixed audio data from the server, passing them to the audio
    // player for listening purposes.
    socket.on('playaudio', (audio) {
      if (_isRecording) {
        print('I hear something!');

        final List<double> audioData = new List<double>.from(audio);
        _bufferPlayer.playAudio(audioData);
      }
    });

    // Alerts the objects associated with the Performer/Listener
    // the (Player/Streamer) and updates the Session Screen.
    socket.on('audiostop', (data) {
      _isRecording = false;
      endAudioBehavior();

      // We represent the room as an empty map, containing no members.
      // At this point, non-hosts should be greeted by a success screen!
      _members.sink.add(Map());

      _bufferPlayer = null;
      _audioStreamer = null;
    });

    // Ends the session due to a server error or a host leaving.
    socket.on('roomerror', (data) {
      print('Received roomerror.');
      endAudioBehavior();
      _members.sink.addError(data);
    });
  }

  /// Passes audio from a performer's microphone to the server via sockets.
  void onAudio(List<double> buffer) {
    if (_isRecording) {
      print('(onAudio) buffer.length: ${buffer.length}');
      socket.emitWithBinary('sendaudio', [buffer]);
    }
  }

  /// Sets up room metadata and attributes it to a user, passing it to the
  /// server.
  void createRoom(String username) {
    currentRoom = username;

    final Map<String, dynamic> room = {
      'id': username,
      'host': username,
      'maxPerformers': _numPerformers.value,
      'maxListeners': 3,
      'currentPerformers': _role.value == Role.PERFORMER ? 1 : 0,
      'currentListeners': _role.value == Role.LISTENER ? 1 : 0,
      'pin': _pin.value,
    };

    final Map<String, dynamic> member = {
      'username': username,
      'isActive': true,
      'role': _role.value == Role.LISTENER ? 0 : 1,
      'isGuest': false,
      'isHost': true
    };

    socket.emit('createroom', <String, dynamic>{
      'room': room,
      'member': member,
    });

    setupAudioBehavior();
  }

  /// Sends a user's metadata to the server and alerting the server about an
  /// intent to join the specified room.
  void joinRoom(String roomId, String joiningUser) {
    currentRoom = roomId;

    final Map<String, dynamic> member = {
      'socket': socket.id,
      'username': joiningUser,
      'isActive': true,
      'role': _role.value == Role.LISTENER ? 0 : 1,
      'isGuest': joiningUser == null ? true : false,
      'isHost': false
    };

    socket.emit(
        'joinroom', <String, dynamic>{'roomId': roomId, 'member': member});

    setupAudioBehavior();
  }

  /// Starts the audio recording session between the members of the room.
  /// The button that activates this is only visible to the host.
  ///
  /// A timer begins counting down, as recordings can only last up to a
  /// maximum of 10 minutes (600 seconds).
  void startSession() {
    print('(startSession method) _isRecording: $_isRecording');
    socket.emit('startsession', currentRoom);
  }

  /// Ends the session between the members of the room.
  /// Any immediately important composition metadata is passed via an API call.
  /// (Examples: Composer name, composition runtime in seconds)
  ///
  /// The button that activates this is only visible to the host.
  Future<String> endSession(String composer, int runtimeInSeconds) async {
    print('Time elapsed: $runtimeInSeconds seconds.');

    final performerNames = List<String>();

    for (String socketId in _members.value.keys) {
      // Guests, bearing no name, are stripped from credit as performers.
      if (!socketId.startsWith('(')) {
        performerNames.add(_members.value[socketId].username);
      }
    }

    final composition = <String, dynamic>{
      'composer': composer,
      'time': runtimeInSeconds,
      'performers': performerNames,
    };

    final compositionId = await _compositionRepo.createComposition(composition);
    socket.emit('endsession', currentRoom);

    return compositionId;
  }

  /// TODO: Finish comments
  void leaveRoom(String roomId) {
    socket.emit('leaveroom', roomId);
    endAudioBehavior();
  }

  void updateRooms() {
    socket.emit('updaterooms', null);
  }

  void validateExistingPin(String roomId, String enteredPin) {
    if (enteredPin.length == 4) {
      print('TOTAL: $enteredPin');
      socket.emit('verifypin',
          <String, dynamic>{'roomId': roomId, 'enteredPin': enteredPin});
    } else {
      print(enteredPin);
      _pin.addError('Pin must be 4 digits.');
    }
  }

  void validateNewPin(String enteredPin) {
    if (enteredPin.length == 4) {
      _pin.sink.add(enteredPin);
    } else {
      _pin.addError('Pin must be 4 digits.');
    }
  }

  void setupAudioBehavior() {
    print('currentRole: $currentRole');
    if (currentRole == Role.LISTENER) {
      _bufferPlayer = AudioBufferPlayer();
      _audioStreamer = null;
    } else {
      _audioStreamer = AudioStreamer();
      _bufferPlayer = null;
    }
  }

  void endAudioBehavior() {
    if (currentRole == Role.LISTENER) {
      if (_bufferPlayer != null) {
        _bufferPlayer.stopAudio();
      }
    } else {
      if (_audioStreamer != null) {
        _audioStreamer.stop();
      }
    }
  }

  Future<StatusModel> submitCompositionInfo(String title, String description,
      List<String> tags, bool isPrivate) async {
    final compositionInfo = <String, dynamic>{
      'title': title,
      'description': description,
      'tags': tags,
      'private': isPrivate,
    };

    return await _compositionRepo.editComposition(compositionInfo);
  }

  void dispose() {
    pinText.dispose();
    _rooms.close();
    _createRoomValid.close();
    _joinRoomValid.close();
    _members.close();
    _pin.close();
    _numPerformers.close();
    _role.close();

    socket.disconnect();
  }
}
