import 'dart:async';
import 'dart:convert';
import 'package:audio_buffer_player/audio_buffer_player.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../constants/base_url.dart';
import '../../constants/role.dart';
import '../../models/member_model.dart';
import '../../models/room_model.dart';

class RoomBloc {
  // AppointmentScreen
  final pinText = TextEditingController();
  final _rooms = BehaviorSubject<Map<String, RoomModel>>();
  final _pin = BehaviorSubject<String>();
  final _numPerformers = BehaviorSubject<int>();
  final _role = BehaviorSubject<Role>();
  final _createRoomValid = BehaviorSubject<bool>();
  final _joinRoomValid = BehaviorSubject<bool>();

  // SessionScreen
  final _members = BehaviorSubject<Map<String, MemberModel>>();
  final _sessionReady = BehaviorSubject<bool>();
  final _jsonEncoder = JsonEncoder();

  String currentRoom;
  Socket socket;
  Role currentRole;
  MemberModel currentMember;
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

    onSocketConnections();
    socket.connect();
  }

  /// Encompasses all socket.on connections required for the
  /// app's socket.io behavior.
  void onSocketConnections() {
    // Updates list of available rooms in host screen
    socket.on('updaterooms', (data) {
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

      if (data.length == _numPerformers.value) {
        _sessionReady.sink.add(true);
      } else {
        _sessionReady.addError('');
      }

      _members.sink.add(membersMap);
    });

    socket.on('verifypin', (data) {
      print('data: $data');
      if (data != null) {
        _pin.add(data);
      } else {
        _pin.addError(data);
      }
    });

    socket.on('audiostart', (data) {
      print('(audiostart socket) _isRecording: $_isRecording');
      _isRecording = true;
      if (currentRole == Role.LISTENER) {
        _bufferPlayer.init();
      } else {
        _audioStreamer.start(onAudio);
      }
    });

    socket.on('playaudio', (audio) {
      print('(playaudio socket) _isRecording: $_isRecording');
      if (_isRecording) {
        print('I hear something!');

        final List<double> audioData = new List<double>.from(jsonDecode(audio));
        _bufferPlayer.playAudio(audioData);
      }
    });

    socket.on('audiostop', (data) {
      _isRecording = false;
      endAudioBehavior();

      _bufferPlayer = null;
      _audioStreamer = null;
    });

    socket.on('roomerror', (data) {
      print('Received roomerror.');
      endAudioBehavior();
      _members.sink.addError(data);
    });
  }

  void onAudio(List<double> buffer) {
    if (_isRecording) {
      print('(onAudio) buffer.length: ${buffer.length}');
      socket.emit('sendaudio', _jsonEncoder.convert(buffer));
    }
  }

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

    socket
        .emit('createroom', <String, dynamic>{'room': room, 'member': member});

    setupAudioBehavior();
  }

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

  // The button that activates this is only visible to the host.
  void startSession() {
    print('(startSession method) _isRecording: $_isRecording');
    socket.emit('startsession', currentRoom);
  }

  // Start Session button changes to an "end session" button.
  void endSession(String roomId) {
    socket.emit('endsession', roomId);
  }

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
