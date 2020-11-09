import 'dart:async';

import 'package:audio_buffer_player/audio_buffer_player.dart';

import 'package:audio_streamer/audio_streamer.dart';

import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/constants/role.dart';
import 'package:jct/src/constants/role_limits.dart';
import 'package:jct/src/models/member_model.dart';
import 'package:jct/src/models/room_model.dart';
import 'package:jct/src/models/status_model.dart';
import 'package:jct/src/models/user_model.dart';
import 'package:jct/src/resources/composition_api_repository.dart';

import 'package:rxdart/rxdart.dart';

import 'package:socket_io_client/socket_io_client.dart';

class RoomBloc {
  // Room Screen
  final _rooms = BehaviorSubject<Map<String, RoomModel>>();
  final _pinValid = BehaviorSubject<bool>();
  final _role = BehaviorSubject<Role>();

  // Session Screen
  final _members = BehaviorSubject<Map<String, MemberModel>>();
  final _sessionHasBegun = BehaviorSubject<bool>();
  final _isActive = BehaviorSubject<bool>();
  final _audioStopped = BehaviorSubject<bool>();
  final _compositionRepo = CompositionApiRepository();

  String currentRoom;
  Socket socket;
  Role currentRole;
  AudioStreamer _audioStreamer;
  AudioBufferPlayer _bufferPlayer;
  Timer timer;
  Stopwatch watch;

  Function(Role) get changeRole => _role.sink.add;

  Stream<Map<String, RoomModel>> get rooms => _rooms.stream;
  Stream<Map<String, MemberModel>> get members => _members.stream;
  Stream<Role> get role => _role.stream;
  Stream<bool> get pinValid => _pinValid.stream;
  Stream<bool> get sessionHasBegun => _sessionHasBegun.stream;
  Stream<bool> get isActive => _isActive.stream;

  RoomBloc() {
    _role.sink.add(Role.LISTENER);
    initSocket();
  }

  /// Handles socket initialization at the creation of a RoomBloc.
  void initSocket() {
    socket = io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'upgrade': false,
      'reconnection': false,
      'timeout': 1200000,
    });

    onSocketConnections();
  }

  void connectSocket() {
    socket.connect();
  }

  void disconnectSocket() {
    socket.disconnect();
    _rooms.sink.add(null);
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
      final Map<String, dynamic> members = data['members'];
      final sessionStarted = data['sessionStarted'];

      for (String key in members.keys) {
        membersMap[key] = MemberModel.fromJson(members[key]);
      }

      // If the session has yet to begin, allow/disallow the host to press the
      // start session button, given that the room's performer capacity is met.
      if (_sessionHasBegun.value != true) {
        if (sessionStarted == true) {
          print('Joining in the middle of a session.');
          _sessionHasBegun.sink.add(true);
          _isActive.sink.add(true);

          if (currentRole == Role.LISTENER) {
            _bufferPlayer = AudioBufferPlayer();
            _audioStreamer = null;
          }
        }
        // TODO: Change back minimum performers for session
        else if (data['members'].length >= MIN_PERFORMERS) {
          _sessionHasBegun.sink.add(false);
        } else {
          _sessionHasBegun.add(null);
        }
      }

      _members.sink.add(membersMap);
    });

    // Socket message that denotes success for an entered PIN that was
    // consistent with an existing room's PIN.
    socket.on('pinsuccess', (data) {
      _pinValid.sink.add(true);
    });

    // Failure socket message that occurred for a PIN entry.
    // TODO: Test this locally, get server code from interwebs
    socket.on('pinerror', (err) {
      _pinValid.addError(err);
    });

    // Socket event for when an audio recording session finally begins.
    // We capture the list of performers in our composition at this stage.
    socket.on('audiostart', (data) {
      _sessionHasBegun.sink.add(true);
      _isActive.sink.add(true);

      if (currentRole == Role.PERFORMER) {
        _audioStreamer.start(onAudio);
      }
    });

    // Receives mixed audio data from the server, passing them to the audio
    // player for listening purposes.
    socket.on('playaudio', (audio) {
      if (_bufferPlayer != null) {
        _bufferPlayer.playAudio(List<int>.from(audio));
      }
    });

    // Alerts the objects associated with the Performer/Listener
    // the (Player/Streamer) and updates the Session Screen.
    socket.on('audiostop', (data) {
      endAudioBehavior();

      // We represent the room as an empty map, containing no members.
      // At this point, non-hosts should be greeted by a success screen!
      _members.sink.add(Map());
      _sessionHasBegun.sink.add(false);

      // _bufferPlayer = null;
      // _audioStreamer = null;
    });

    // Ends the session due to a server error or a host leaving.
    socket.on('roomerror', (data) {
      print('Received roomerror.');
      endAudioBehavior();
      _sessionHasBegun.sink.add(null);
      _members.sink.addError(data);
      socket.emit('updaterooms', null);
    });
  }

  /// Sets up room metadata and attributes it to a user, passing it to the
  /// server.
  void createRoom(String username, bool hasPin, String enteredPin) {
    currentRoom = username;
    _sessionHasBegun.sink.add(null);
    _isActive.sink.add(null);
    _members.sink.add(null);

    final Map<String, dynamic> room = {
      'id': username,
      'host': username,
      'maxPerformers': MAX_PERFORMERS,
      'maxListeners': 3,
      'currentPerformers': _role.value == Role.PERFORMER ? 1 : 0,
      'currentListeners': _role.value == Role.LISTENER ? 1 : 0,
      'hasPin': hasPin,
      'pin': hasPin ? enteredPin : null,
    };

    final Map<String, dynamic> member = {
      'name': username,
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

  /// Verifies the user's entered PIN by passing it to the server for comparing.
  void verifyPin(String roomId, String enteredPin) {
    socket.emit('verifypin', <String, dynamic>{
      'roomId': roomId,
      'enteredPin': enteredPin,
    });
  }

  /// Sends a user's metadata to the server and alerting the server about an
  /// intent to join the specified room.
  void joinRoom(String roomId, String joiningUser) {
    currentRoom = roomId;

    _isActive.sink.add(null);
    _members.sink.add(null);
    _sessionHasBegun.sink.add(null);

    final Map<String, dynamic> member = {
      'socket': socket.id,
      'name': joiningUser,
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
  /// maximum of MAX_COMPOSITION_TIME.
  void startSession() {
    socket.emit('startsession', currentRoom);
  }

  /// Passes audio from a performer's microphone to the server via sockets.
  void onAudio(List<int> buffer) {
    if (_sessionHasBegun.value == true) {
      socket.emitWithBinary('sendaudio', [buffer]);
    }
  }

  /// Handles the user's decision to mute/unmute or deafen/undeafen themselves
  /// during a session.
  void muteOrDeafen(String roomId, Role role, bool active) async {
    socket.emit('muteordeafen', <String, dynamic>{
      'roomId': roomId,
      'isActive': active,
    });

    if (active) {
      if (role == Role.LISTENER) {
        _bufferPlayer.deafenAudio();
      } else if (role == Role.PERFORMER) {
        await _audioStreamer.stop();
        // _audioStreamer.muteAudio();
      } else {
        print('Role unsupported for setting inactive.');
      }
    } else {
      if (role == Role.LISTENER) {
        _bufferPlayer.undeafenAudio();
      } else if (role == Role.PERFORMER) {
        await _audioStreamer.start(onAudio);
        // _audioStreamer.unmuteAudio();
      } else {
        print('Role unsupported for setting active.');
      }
    }
    _isActive.sink.add(!active);
  }

  /// Exits the guest/user from their current room, canceling audio behavior.
  /// Certain streams are reset in order to refresh user input.
  void leaveRoom(String roomId) {
    resetRoomAndMemberStreams();

    socket.emit('leaveroom', roomId);
    updateRooms();
    endAudioBehavior();
  }

  /// Ends the session between the members of the room.
  /// Any immediately important composition metadata is passed via an API call.
  /// (Examples: Composer name, composition runtime in seconds)
  ///
  /// The button that activates this is only visible to the host.
  Future<String> endSession(UserModel user) async {
    final performerNames = List<String>();

    for (String socketId in _members.value.keys) {
      print('User: ${_members.value[socketId].username}');
      final member = _members.value[socketId];

      if (!member.isGuest && member.role == Role.PERFORMER) {
        performerNames.add(member.username);
      }
    }

    final String compId = await _compositionRepo.generateCompositionID(user.id);
    final composition = <String, dynamic>{
      'id': compId,
      'composer': user.username,
      'performers': performerNames,
    };

    socket.emit('endsession', <String, dynamic>{
      'roomId': currentRoom,
      'composition': composition,
      'user': user.id,
    });

    return compId;
  }

  /// TODO: Finish comments in room_bloc.dart
  void resetRoomAndMemberStreams() {
    _rooms.sink.add(null);
    _pinValid.sink.add(null);
  }

  void updateRooms() {
    socket.emit('updaterooms', null);
  }

  void setupAudioBehavior() {
    print('Setting up user of role: $currentRole.');
    if (currentRole == Role.LISTENER && _bufferPlayer == null) {
      _bufferPlayer = AudioBufferPlayer();
      _audioStreamer = null;
    } else if (_audioStreamer == null) {
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

  Future<StatusModel> submitCompositionInfo(
      {String userId,
      String compositionId,
      String title,
      String description,
      List<String> tags,
      bool isPrivate}) async {
    final data = <String, dynamic>{
      'user': userId,
      'id': compositionId,
      'title': title,
      'description': description,
      'tags': tags,
      'private': isPrivate,
    };

    return await _compositionRepo.editComposition(data);
  }

  void dispose() {
    _rooms.close();
    _members.close();
    _pinValid.close();
    _role.close();
    _sessionHasBegun.close();
    _isActive.close();
    _audioStopped.close();

    socket.disconnect();
  }
}
