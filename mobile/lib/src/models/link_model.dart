class LinkModel {
  final String self;
  final String html;
  // final String download;
  // final String downloadLocation;

  LinkModel.fromJson(Map<String, dynamic> parsedJson)
    :
      self = parsedJson['self'],
      html = parsedJson['html'];
      // download = parsedJson['download'],
      // downloadLocation = parsedJson['download_location'];
}