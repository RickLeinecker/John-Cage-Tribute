import 'package:equatable/equatable.dart';

class RoomModel extends Equatable {
  final String id;
  final String host;
  final bool hasPin;
  final bool sessionStarted;
  final int maxPerformers;
  final int maxListeners;
  final int currentPerformers;
  final int currentListeners;

  RoomModel.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        host = parsedJson['host'],
        hasPin = parsedJson['hasPin'],
        sessionStarted = parsedJson['sessionStarted'],
        maxPerformers = parsedJson['maxPerformers'],
        maxListeners = parsedJson['maxListeners'],
        currentPerformers = parsedJson['currentPerformers'],
        currentListeners = parsedJson['currentListeners'];

  const RoomModel.closedRoom(String host)
      : id = null,
        host = host,
        hasPin = false,
        sessionStarted = false,
        maxPerformers = 0,
        maxListeners = 0,
        currentPerformers = 0,
        currentListeners = 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host': host,
      'hasPin': hasPin,
      'sessionStarted': sessionStarted,
      'maxPerformers': maxPerformers,
      'maxListeners': maxListeners,
      'currentListeners': currentListeners,
      'currentPerformers': currentPerformers,
    };
  }

  bool isClosed() {
    return id == null;
  }

  @override
  List<Object> get props => [id];
}
