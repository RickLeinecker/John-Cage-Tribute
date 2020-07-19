class CompositionModel {
  final String title;
  final String composer;
  final int secs;

  CompositionModel.fromJson(Map<String, dynamic> parsedJson)
      : title = parsedJson['title'],
        composer = parsedJson['composer'],
        secs = parsedJson['secs'];
}
