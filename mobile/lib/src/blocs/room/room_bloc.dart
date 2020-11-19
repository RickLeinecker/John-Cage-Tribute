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
  final _rooms = BehaviorSubject<Map<String, BehaviorSubject<RoomModel>>>();
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
  AudioStreamer _audioStreamer;
  AudioBufferPlayer _bufferPlayer;
  Timer timer;
  Stopwatch watch;

  Function(Role) get changeRole => _role.sink.add;

  Stream<Map<String, BehaviorSubject<RoomModel>>> get rooms => _rooms.stream;
  Stream<Map<String, MemberModel>> get members => _members.stream;
  Stream<Role> get role => _role.stream;
  Stream<bool> get pinValid => _pinValid.stream;
  Stream<bool> get sessionHasBegun => _sessionHasBegun.stream;
  Stream<bool> get isActive => _isActive.stream;

  Role get currentRole => _role.value;

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
      final Map<String, BehaviorSubject<RoomModel>> roomMap = Map();

      for (String key in data.keys) {
        roomMap[key] = BehaviorSubject.seeded(RoomModel.fromJson(data[key]));
      }

      disposeRooms();
      _rooms.sink.add(roomMap);
    });

    socket.on('updateoneroom', (data) {
      final String roomId = data['roomId'];
      final RoomModel room = data['room'] != null
          ? RoomModel.fromJson(data['room'])
          : RoomModel.closedRoom(roomId);

      if (_rooms.value != null && _rooms.value.containsKey(roomId)) {
        _rooms.value[roomId].sink.add(room);
      }
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
        } else if (data['members'].length >= MIN_PERFORMERS) {
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
    });

    // Ends the session due to a server error or a host leaving.
    socket.on('roomerror', (data) {
      print('Received roomerror.');
      endAudioBehavior();
      _sessionHasBegun.sink.add(null);
      _members.sink.addError(data);
      updateRooms();
    });
  }

  /// Sets up room metadata and attributes it to a user, passing it to the
  /// server. Subsequently, returns the host represented as its member.
  MemberModel createRoom(String username, bool hasPin, String enteredPin) {
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
    return MemberModel.fromJson(
        <String, dynamic>{'username': username, ...member});
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
  MemberModel joinRoom(String roomId, String joiningUser) {
    currentRoom = roomId;

    _isActive.sink.add(null);
    _members.sink.add(null);
    _sessionHasBegun.sink.add(null);
    _pinValid.sink.add(null);

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
    return MemberModel.fromJson(
        <String, dynamic>{'username': joiningUser, ...member});
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
      } else {
        print('Role unsupported for setting inactive.');
      }
    } else {
      if (role == Role.LISTENER) {
        _bufferPlayer.undeafenAudio();
      } else if (role == Role.PERFORMER) {
        await _audioStreamer.start(onAudio);
      } else {
        print('Role unsupported for setting active.');
      }
    }
    _isActive.sink.add(!active);
  }

  /// Exits the user from their current room while canceling audio behavior.
  void leaveRoom(String roomId, bool isHost) {
    resetRoomAndMemberStreams();

    socket.emit('leaveroom', roomId);

    if (!isHost) {
      updateRooms();
    }

    endAudioBehavior();
  }

  /// Ends the session between the members of the room.
  ///
  /// Any immediately important composition metadata is passed via an API call.
  /// The button that activates this is only visible to the host.
  Future<String> endSession(UserModel user) async {
    final performerNames = List<String>();

    for (String socketId in _members.value.keys) {
      final member = _members.value[socketId];
      int numGuests = 0;

      if (member.role == Role.PERFORMER) {
        if (!member.isGuest) {
          performerNames.add(member.username);
        } else {
          numGuests++;
          performerNames.add('Guest $numGuests');
        }
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

  /// Adds null to the rooms list and pin streams, effectively treating them
  /// as empty with no information.
  void resetRoomAndMemberStreams() {
    _rooms.sink.add(null);
    _pinValid.sink.add(null);
  }

  /// Makes a socket call to receive all currently active rooms from the server.
  /// Additionally, refreshes the pinValid stream.
  void updateRooms() {
    _pinValid.sink.add(null);
    socket.emit('updaterooms', null);
  }

  /// Initializes mic/speaker objects in preparation for an audio session.
  /// The object that is initialized is based on which role a user selected.
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

  /// Stops audio functionality on mic/speaker object based on a user's role in
  /// a session.
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

  /// Edits a pre-existing composition's metadata that was provided by the user.
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

  /// Clears all streams/controllers for each room.
  void disposeRooms() {
    if (_rooms.value != null) {
      for (String key in _rooms.value.keys) {
        _rooms.value[key].close();
      }
    }
  }

  /// Closes streams and disconnects socket.
  void dispose() {
    disposeRooms();
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
