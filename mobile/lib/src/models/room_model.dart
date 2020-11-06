class RoomModel {
  final String id;
  final String host;
  final bool hasPin;
  final int maxPerformers;
  final int maxListeners;
  final int currentPerformers;
  final int currentListeners;

  RoomModel.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        host = parsedJson['host'],
        hasPin = parsedJson['hasPin'],
        maxPerformers = parsedJson['maxPerformers'],
        maxListeners = parsedJson['maxListeners'],
        currentPerformers = parsedJson['currentPerformers'],
        currentListeners = parsedJson['currentListeners'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host': host,
      'hasPin': hasPin,
      'maxPerformers': maxPerformers,
      'maxListeners': maxListeners,
      'currentListeners': currentListeners,
      'currentPerformers': currentPerformers,
    };
  }
}
